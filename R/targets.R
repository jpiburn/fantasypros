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

  if (missing(season)) season <- as.numeric(format(Sys.Date(), "%Y"))

  fp_query_list <- fp_build_query_list(season = season)
  pos_path <- fp_format_pos_path(pos)

  fp_url <- fp_build_url(
    path_list = list("nfl", "reports", "targets", pos_path)
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

#' NFL team target distributions
#'
#' @param season \code{Numeric}. The NFL season. If missing it will return the current year's season.
#'               Supported season only go back to \code{2013}
#' @param start_week \code{Numeric}. The starting week. Default is \code{1}
#' @param end_week \code{Numeric}. The ending week. Default is \code{17}
#' @return a tibble
#' @export
#'
#' @examples
#'
#' fp_team_targets(season = 2018)
#'
#' # total targets for TE's in the 2014 season
#' fp_team_targets(season = 2014, start_week = 8, end_week = 10)
#'
fp_team_targets <- function(season, start_week = 1, end_week = 17) {

  if (missing(season)) season <- as.numeric(format(Sys.Date(), "%Y"))

  fp_query_list <- fp_build_query_list(
    season     = season,
    start_week = start_week,
    end_week   = end_week
    )

  # skipping the positinal breakdowns for now
  # pos_path <- fp_format_pos_path(pos)

  fp_url <- fp_build_url(
    path_list = list("nfl", "reports", "targets-distribution")
  )

  fp_url$query <- fp_query_list
  fp_url_string <- httr::build_url(fp_url)
  fpdf <- fp_get_data(fp_url_string)
  fpdf <- tibble::add_column(fpdf,
                             season     = season,
                             start_week = start_week,
                             end_week   = end_week,
                             .after     = "team"
  )

  fpdf
}

