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
#' fp_snaps(season = 2018)
#'
#' # Percentage of total game snaps for TE's in the 2018 season
#' fp_snaps(pos = "TE", season = 2018, percentage = TRUE)
#'
#' # all defensive positions for the current NFL season.
#' fp_snaps(pos = "defense")
fp_snaps <- function(pos = "offense", season, percentage = FALSE) {

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

  fp_snap_url <- paste0(
    "https://www.fantasypros.com/nfl/reports/snap-counts/",
    pos_url, "?", season_url, "&", perc_url
  )

  snap_html <- xml2::read_html(fp_snap_url)
  snapdf <- rvest::html_table(snap_html)[[1]]

  num_cols <- setdiff(names(snapdf), c("Player", "Pos", "Team"))
  snapdf[num_cols][] <- lapply(snapdf[num_cols], function(x) gsub("bye", NA, x))
  snapdf[num_cols][] <- lapply(snapdf[num_cols], readr::parse_number)

  snapdf <- tibble::add_column(snapdf, "season" = season, .after = "Team")

  clean_names <- janitor::make_clean_names(names(snapdf))
  clean_names <- gsub(pattern = "x", replacement = "w", clean_names)
  names(snapdf) <- clean_names

  tibble::as_tibble(snapdf)
}
