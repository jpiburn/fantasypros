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

  if (missing(season)) season <- as.numeric(format(Sys.Date(), "%Y"))
  if (percentage) show <- "perc"
  else show <- "count"

  fp_query_list <- fp_build_query_list(season = season,
                                       show   = show
                                       )

  pos_path <- fp_format_pos_path(pos)

  fp_url <- fp_build_url(
    path_list = list("nfl", "reports", "snap-counts", pos_path)
  )

  fp_url$query <- fp_query_list
  fp_url_string <- httr::build_url(fp_url)
  fpdf <- fp_get_data(fp_url_string)
  fpdf <- tibble::add_column(fpdf,
                             season = season,
                             .after = "team"
                             )

  fpdf
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
#' @param scoring \code{Charcater}. Fantasy scoring format. Default is \code{"half"}
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
#' fp_snap_analysis(pos = "TE", season = 2017, scoring = "std")
#'
#' # all defensive positions for the current NFL season in week 1
#' fp_snap_analysis(pos = "defense", start_week = 1, end_week = start_week)
fp_snap_analysis <- function(pos = "offense", season, start_week = 1, end_week = 17,
                             scoring = c("half", "ppr", "std")) {

  scoring <- match.arg(scoring)
  if (missing(season)) season <- as.numeric(format(Sys.Date(), "%Y"))

  fp_query_list <- fp_build_query_list(season = season,
                                       scoring = scoring,
                                       start_week = start_week,
                                       end_week = end_week,
                                       snaps = 0
                                       )

  pos_path <- fp_format_pos_path(pos)

  fp_url <- fp_build_url(
    path_list = list("nfl", "reports", "snap-count-analysis", pos_path)
    )

  fp_url$query <- fp_query_list
  fp_url_string <- httr::build_url(fp_url)
  fpdf <- fp_get_data(fp_url_string)

  fpdf <- tibble::add_column(fpdf,
                             season     = season,
                             start_week = start_week,
                             end_week   = end_week,
                             scoring    = scoring,
                             .after     = "team")

  fpdf
}
