#' NFL Positional Statistics
#'
#' @param pos \code{Charcater}. Specific position you want to return. Default will return all
#'            all offensive postions. Available options include
#'            \itemize{
#'             \item \code{"QB"}
#'             \item \code{"RB"}
#'             \item \code{"WR"}
#'             \item \code{"TE"}
#'             \item \code{"K"}
#'             \item \code{"DST"}
#'             \item \code{"DL"}
#'             \item \code{"LB"}
#'             \item \code{"DB"}
#'            }
#' @param season \code{Numeric}. The NFL season. If missing it will return the current year's season.
#'               Supported season only go back to \code{2015}
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
#' # overall fantasy points for the entire season
#' fp_stats("RB", season = 2018)
#'
#' # TE's in the 2017 season using standard scoring
#' fp_stats(pos = "TE", season = 2017, scoring = "std")
#'
fp_stats <- function(pos = "QB", season, start_week = 1, end_week = 17,
                              scoring = c("half", "ppr", "std")) {

  scoring <- match.arg(scoring)
  if (missing(season)) season <- as.numeric(format(Sys.Date(), "%Y"))

  fp_query_list <- fp_build_query_list(
    season     = season,
    range      = "custom",
    start_week = start_week,
    end_week   = end_week,
    scoring    = scoring
  )

  # The stats url is start_week and end_week.
  # This is different then the others that are just start and end.
  start_index <- which(names(fp_query_list) == "start")
  names(fp_query_list)[start_index] <- "start_week"

  end_index <- which(names(fp_query_list) == "end")
  names(fp_query_list)[end_index] <- "end_week"

  pos_path <- fp_format_pos_path(pos)

  fp_url <- fp_build_url(
    path_list = list("nfl", "stats", pos_path)
  )

  fp_url$query <- fp_query_list
  fp_url_string <- httr::build_url(fp_url)
  fpdf <- fp_get_stats_data(fp_url_string, pos = tolower(pos))

  fpdf <- tibble::add_column(fpdf,
                             season     = season,
                             start_week = start_week,
                             end_week   = end_week,
                             scoring    = scoring,
                             .after     = "team")

  fpdf
}
