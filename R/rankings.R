#' Fantasy Pros Expert Consensus Draft Rankings
#'
#' @param pos \code{Charcater}. Specific position you want to return. Default will return overall.
#'            Available options include
#'            \itemize{
#'             \item \code{"overall"}
#'             \item \code{"QB"}
#'             \item \code{"RB"}
#'             \item \code{"WR"}
#'             \item \code{"TE"}
#'             \item \code{"K"}
#'             \item \code{"DST"}
#'             \item \code{"IDP"}
#'             \item \code{"DL"}
#'             \item \code{"LB"}
#'             \item \code{"DB"}
#'             \item \code{"Team QB"}
#'             \item \code{"Team RB"}
#'             \item \code{"Team WR"}
#'             \item \code{"Team TE"}
#'             \item \code{"Team K"}
#'             \item \code{"Team OL"}
#'             \item \code{"Head Coach"}
#'            }
#' @param scoring \code{Charcater}. Fantasy scoring format. Default is \code{"half"}
#'
#' @return a tibble
#' @export
#'
#' @examples
#'
#' # overall ECR for half point ppr
#' fp_draft_rankings()
#'
#' # TE ECR using standard scoring
#' fp_draft_rankings(pos = "TE", scoring = "std")
#'
#' # Individual Defensive Player ECR
#' fp_draft_rankings(pos = "IDP")
fp_draft_rankings <- function(pos = "overall", scoring = c("half", "ppr", "std")) {

  scoring <- match.arg(scoring)

  pos_path <- fp_format_rankings_pos_path(scoring = scoring, pos = pos)

  fp_url <- fp_build_url(
    path_list = list("nfl", "rankings", pos_path)
  )

  fp_url_string <- httr::build_url(fp_url)
  fpdf <- fp_get_ranking_data(fp_url_string, pos = pos)
  fpdf <- tibble::add_column(fpdf,
                             scoring = scoring,
                             .before  = "rank")

  fpdf
}
