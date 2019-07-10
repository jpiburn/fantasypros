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
