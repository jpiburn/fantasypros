#' Target Counts by Week
#'
#' @param pos \code{Charcater}. Specific position you want to return. Default will return all
#'            all offensive postions. Available options include
#'            \itemize{
#'             \item \code{"offense"}
#'             \item \code{"RB"}
#'             \item \code{"WR"}
#'             \item \code{"TE"}
#'            }
#' @param season \code{Numeric}. The NFL season. If missing it will return the current year's season.
#'               Supported season only go back to \code{2013}
#'
#' @return a tibble
#' @export
#'
#' @note \itemize{
#'       \item Bye weeks and games players did not play in are represented as \code{NA}
#'        }
#'
#' @examples
#'
#' # all offensive positions for the 2018 season
#' fp_targets(season = 2018)
#'
#' # total targets for TE's in the 2014 season
#' fp_targets(pos = "TE", season = 2014)
#'
#' # all WR targets for the current NFL season.
#' fp_targets(pos = "WR")
fp_targets <- function(pos = "offense", season) {

  if (missing(pos)) pos <- "offense"
  else pos <- tolower(pos)

  if (missing(season)) season <- as.numeric(format(Sys.Date(), "%Y"))

  season_url <- paste0("year=", season)

  pos_url <- switch(pos,
                    "offense" = "",
                    "off"     = "",
                    "rb"      = "rb.php",
                    "wr"      = "wr.php",
                    "te"      = "te.php"
                    )

  if (is.null(pos_url)) {
    warning(
      paste("position", pos, "not recognized. Defaulting to all offensive positions"),
      call. = FALSE
    )
    pos_url <- ""
  }

  fp_url <- paste0(
    "https://www.fantasypros.com/nfl/reports/targets/",
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
