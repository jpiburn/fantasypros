#' NFL Snap Counts by Week
#'
#' @param pos \code{Charcater}. Specific position you want to return. Default will return all
#'            all offensive postions. Available options include
#'            \itemize{
#'             \item \code{"offense"}
#'             \item \code{"QB"}
#'             \item \code{"RB"}
#'             \item \code{"WR"}
#'             \item \code{"TE"}
#'             \item \code{"Defense"}
#'             \item \code{"DL"}
#'             \item \code{"LB"}
#'             \item \code{"DB"}
#'            }
#' @param season \code{Numeric}. The NFL season. If missing it will return the current year's season.
#'               Supported season only go back to \code{2016}
#' @param percentage \code{Logical}. Return counts as percentages? Default is \code{FALSE}
#'
#' @return a tibble
#' @export
#'
#' @note \itemize{
#'        \item Due to how fantasypros returns the data, all player's teams are listed under their
#'       current team regardless of what season you query.
#'       \item Bye weeks are represented as \code{NA}
#'        }
#'
#' @examples
#'
#' # all offensive positions for the 2018 season
#' fp_snap_counts(season = 2018)
#'
#' # Percentage of total game snaps for TE's in the 2018 season
#' fp_snap_counts(pos = "TE", season = 2018, percentage = TRUE)
#'
#' # all defensive positions for the current NFL season.
#' fp_snap_counts(pos = "defense")
fp_snap_counts <- function(pos = "offense", season, percentage = FALSE) {

  if (missing(pos)) pos <- "offense"
  else pos <- tolower(pos)

  if (percentage) perc_url <- "show=perc"
  else perc_url <- "show=count"

  if (missing(season)) season <- as.numeric(format(Sys.Date(), "%Y"))

  season_url <- paste0("year=", season)

  pos_url <- switch(pos,
                    "offense" = "",
                    "off"     = "",
                    "qb"      = "qb.php",
                    "rb"      = "rb.php",
                    "wr"      = "wr.php",
                    "te"      = "te.php",
                    "def"     = "defense.php",
                    "defense" = "defense.php",
                    "dl"      = "dl.php",
                    "lb"      = "lb.php",
                    "db"      = "db.php")

  if (is.null(pos_url)) {
    warning(
      paste("position", pos, "not recognized. Defaulting to offense only."),
      call. = FALSE
    )
    pos_url <- ""
  }

  fp_url <- paste0(
    "https://www.fantasypros.com/nfl/reports/snap-counts/",
    pos_url, "?", season_url, "&", perc_url
  )

  fp_html <- xml2::read_html(fp_url)
  fpdf <- rvest::html_table(fp_html)[[1]]

  num_cols <- setdiff(names(fpdf), c("Player", "Pos", "Team"))
  fpdf[num_cols][] <- lapply(fpdf[num_cols], function(x) gsub("bye|-", NA, x))
  fpdf[num_cols][] <- lapply(fpdf[num_cols], readr::parse_number)

  fpdf <- tibble::add_column(fpdf, "season" = season, .after = "Team")

  clean_names <- janitor::make_clean_names(names(fpdf))
  clean_names <- gsub(pattern = "x", replacement = "w", clean_names)
  names(fpdf) <- clean_names

  tibble::as_tibble(fpdf)
}

#' Detailed Analysis of NFL snap counts
#'
#' @param pos \code{Charcater}. Specific position you want to return. Default will return all
#'            all offensive postions. Available options include
#'            \itemize{
#'             \item \code{"offense"}
#'             \item \code{"QB"}
#'             \item \code{"RB"}
#'             \item \code{"WR"}
#'             \item \code{"TE"}
#'             \item \code{"Defense"}
#'             \item \code{"DL"}
#'             \item \code{"LB"}
#'             \item \code{"DB"}
#'            }
#' @param season \code{Numeric}. The NFL season. If missing it will return the current year's season.
#'               Supported season only go back to \code{2016}
#' @param start_week \code{Numeric}. The starting week. Default is \code{1}
#' @param end_week \code{Numeric}. The ending week. Default is \code{17}
#' @param format \code{Charcater}. Scoring format. \code{"half"}, \code{"ppr"}, \code{"std"}.
#'               The default is \code{"half"}
#'
#' @return a tibble
#' @export
#'
#' @note \itemize{
#'       \item If you query a single week all players that were on a bye that week are not returned
#'        }
#'
#' @examples
#'
#' # all offensive positions for weeks 5-9 of the 2018 season
#' fp_snap_analysis(season = 2018, start_week = 5, end_week = 9)
#'
#' # TE's in the 2017 season using standard scoring
#' fp_snap_analysis(pos = "TE", season = 2017, format = "std")
#'
#' # all defensive positions for the current NFL season in week 1
#' fp_snap_analysis(pos = "defense", start_week = 1, end_week = start_week)
fp_snap_analysis <- function(pos = "offense", season, start_week = 1, end_week = 17,
                             format = c("half", "ppr", "std")) {

  format <- match.arg(format)

  if (missing(pos)) pos <- "offense"
  else pos <- tolower(pos)

  if (missing(season)) season <- as.numeric(format(Sys.Date(), "%Y"))
  season_url <- paste0("year=", season)

  format_url <- paste0("scoring=", toupper(format))

  week_url <- paste0("start=", start_week, "&", "end=", end_week)

  snaps_url <- "snaps=0"

  pos_url <- switch(pos,
                    "offense" = "",
                    "off"     = "",
                    "qb"      = "qb.php",
                    "rb"      = "rb.php",
                    "wr"      = "wr.php",
                    "te"      = "te.php",
                    "def"     = "defense.php",
                    "defense" = "defense.php",
                    "dl"      = "dl.php",
                    "lb"      = "lb.php",
                    "db"      = "db.php")

  if (is.null(pos_url)) {
    warning(
      paste("position", pos, "not recognized. Defaulting to offense only."),
      call. = FALSE
    )
    pos_url <- ""
  }

  query_url <- paste(season_url, week_url, snaps_url, format_url, sep = "&")



  fp_url <- paste0(
    "https://www.fantasypros.com/nfl/reports/snap-count-analysis/",
    pos_url, "?", query_url
  )

  fp_html <- xml2::read_html(fp_url)
  fpdf <- rvest::html_table(fp_html)[[1]]

  num_cols <- setdiff(names(fpdf), c("Player", "Pos", "Team"))
  fpdf[num_cols][] <- lapply(fpdf[num_cols], function(x) gsub("bye|-$", NA, x))
  fpdf[num_cols][] <- lapply(fpdf[num_cols], readr::parse_number)

  fpdf <- tibble::add_column(fpdf,
                             season     = season,
                             start_week = start_week,
                             end_week   = end_week,
                             format     = format,
                             .after     = "Team")

  clean_names <- janitor::make_clean_names(names(fpdf))
  clean_names <- gsub(pattern = "x", replacement = "w", clean_names)
  names(fpdf) <- clean_names

  tibble::as_tibble(fpdf)
}
