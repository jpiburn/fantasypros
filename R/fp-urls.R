fp_build_query_list <- function(season     = NULL,
                                start_week = NULL,
                                end_week   = NULL,
                                scoring    = NULL,
                                snaps      = NULL,
                                show       = NULL,
                                format     = NULL
) {

  if (!is.null(scoring)) scoring <- toupper(scoring)

  query_list <- list(
    year    = season,
    start   = start_week,
    end     = end_week,
    scoring = scoring,
    snaps   = snaps,
    show    = show,
    format  = format
  )
  query_list
}


fp_build_url <- function(base = "https://www.fantasypros.com", path_list = NULL){
  fp_url <- httr::parse_url(base)
  fp_url$path <- path_list

  fp_url
}

fp_format_pos_path <- function(pos = NULL) {

  if (is.null(pos)) return("")

  pos <- tolower(pos)
  pos_path <- switch(pos,
                     "offense" = "",
                     "off"     = "",
                     "overall" = "",
                     "qb"      = "qb.php",
                     "rb"      = "rb.php",
                     "wr"      = "wr.php",
                     "te"      = "te.php",
                     "k"       = "k.php",
                     "dst"     = "dst.php",
                     "idp"     = "idp.php",
                     "def"     = "defense.php",
                     "defense" = "defense.php",
                     "dl"      = "dl.php",
                     "lb"      = "lb.php",
                     "db"      = "db.php")

  if (is.null(pos_path)) {
    warning(
      paste("position", pos, "not recognized. Defaulting to offense only."),
      call. = FALSE
    )
    pos_path <- ""
  }

  pos_path
}

fp_get_data <- function(url, skip_parse_cols = c("Player", "Pos", "Team")) {
  fp_html <- xml2::read_html(url)
  fpdf <- rvest::html_table(fp_html)[[1]]

  num_cols <- setdiff(names(fpdf), skip_parse_cols)
  fpdf[num_cols][] <- lapply(fpdf[num_cols], function(x) gsub("bye|-$", NA, x))
  fpdf[num_cols][] <- lapply(fpdf[num_cols], readr::parse_number)

  clean_names <- janitor::make_clean_names(names(fpdf))
  clean_names <- gsub(pattern = "x", replacement = "w", clean_names)
  names(fpdf) <- clean_names

  tibble::as_tibble(fpdf)
}

fp_format_rankings_pos_path <- function(scoring, pos) {

  if (is.null(pos)) return("consensus-cheatsheets.php")

  pos <- tolower(pos)

  if (pos == "overall") {
    pos_path <- switch(scoring,
                       "std"  = "consensus-cheatsheets.php",
                       "half" = "half-point-ppr-cheatsheets.php",
                       "ppr"  = "ppr-cheatsheets.php"
                       )
    return(pos_path)
    }

  if (pos %in% c("rb", "wr", "te")) {
    if (scoring == "half") pos_prepend <- "half-point-ppr-"
    else if (scoring == "ppr") pos_prepend <- "ppr-"
    else pos_prepend <- ""
  }
  else{
  pos_prepend <- ""
  }

  pos_path <- paste0(pos_prepend, pos, "-cheatsheets.php")

  gsub("\\s", "-", pos_path)
}


fp_get_ranking_data <- function(url, pos) {

  fp_html <- xml2::read_html(url)
  fpdf <- rvest::html_table(fp_html, fill = TRUE)[[1]]
  fpdf <- fpdf[ , !is.na(names(fpdf))]

  # depending on which position you query this column is named differntly
  # so rename it up front
  player_info_col <- which(grepl("team", names(fpdf), ignore.case = TRUE))
  names(fpdf)[player_info_col] <- "player_info"

  junk_cols <- names(fpdf) %in% c(NA, "WSID", "Notes", "WSIS")
  fpdf <- fpdf[ , !junk_cols]

  junk_rows <- grepl("\r|\n|function\\(\\)|}\\);|&nbsp", fpdf$player_info)
  fpdf <- fpdf[!junk_rows, ]

  fpdf <- dplyr::mutate(fpdf,
            tier = dplyr::case_when(
              grepl("Tier", Rank) ~ readr::parse_number(Rank)
             )
            )
  fpdf <- tidyr::fill(fpdf, tier)

  num_cols <- !grepl("player_info|pos|tier|notes", names(fpdf), ignore.case = TRUE)
  num_cols <- names(fpdf)[num_cols]
  fpdf[num_cols][] <- lapply(fpdf[num_cols], readr::parse_number)

  fpdf$player_info <- readr::parse_character(fpdf$player_info)
  fpdf <- fpdf[!is.na(fpdf$player_info), ]

  fpdf$player <- gsub("(?<=[a-z]|I|V|Jr\\.)[A-Z]\\..*|\\(.*\\).* ",
                      replacement = "",
                      fpdf$player_info, perl = TRUE)
  fpdf$team <- sapply(stringr::str_split(fpdf$player_info, " "),
                      function(x) x[length(x)]
  )

  if (!"Pos" %in% names(fpdf)) fpdf$Pos <- paste0(pos, fpdf$Rank)

  fpdf$pos <- gsub("[0-9]", "", fpdf$Pos)
  fpdf$pos_rank <- readr::parse_number(fpdf$Pos)
  fpdf$player_info <- NULL
  fpdf$Pos <- NULL

  fpdf <- dplyr::select(fpdf,
                        Rank,
                        tier:pos_rank,
                        dplyr::everything()
  )

  fpdf <- janitor::clean_names(fpdf)
  tibble::as_tibble(fpdf)
}


fp_get_stats_data <- function(url, pos) {

  fp_html <- xml2::read_html(url)
  fpdf <- rvest::html_table(fp_html, fill = TRUE)[[1]]

  if (pos %in% c("qb", "rb", "wr", "te")) {
    first_row_names <- fpdf[1 , ]
    second_row_names <- fpdf[2 , ]

    new_row_names <- paste(first_row_names, second_row_names, sep = "_")
    new_row_names <- gsub("^_|MISC_", "", new_row_names, ignore.case = TRUE)

    fpdf <- fpdf[3:nrow(fpdf), ]
    names(fpdf) <- new_row_names
  }

  fpdf$player <- gsub("\\s\\(.*", "", fpdf$Player, perl = TRUE)
  fpdf$team <- gsub(".*\\s|\\(|\\)", "", fpdf$Player)
  fpdf$pos <- toupper(pos)
  fpdf$Player <- NULL

  # this gets columns that are already numbers
  num_cols <- which(grepl("player|team|pos", names(fpdf), ignore.case = TRUE))
  already_numeric <- which(sapply(1:ncol(fpdf), function(i) class(fpdf[, i])) != "character")

  num_cols <- sort(unique(c(num_cols, already_numeric)))
  num_cols <- setdiff(1:ncol(fpdf), num_cols)
  num_cols <- names(fpdf)[num_cols]
  fpdf[num_cols][] <- lapply(fpdf[num_cols], readr::parse_number)

  fpdf <- dplyr::select(fpdf,
                        player,
                        pos,
                        team,
                        dplyr::everything()
  )

  fpdf <- janitor::clean_names(fpdf)
  tibble::as_tibble(fpdf)
}
