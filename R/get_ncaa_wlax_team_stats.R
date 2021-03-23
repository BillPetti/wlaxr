#' Get Team Stats for Women's Lacrosse
#'
#' @param team_id The unique team id from the NCAA
#' @param year The season for which you want data.
#' If you want the 2017-18 season, you would use 2018.
#'
#' @import dplyr
#' @import rvest
#' @import stringr
#' @return A data frame
#' @export
#'
#' @examples \dontrun{get_ncaa_wlax_stats(392, 2019)}

get_ncaa_wlax_team_stats <- function(team_id,
                                     year) {

  year_id <- ncaa_stats_year_lu_table[which(ncaa_stats_year_lu_table$season == year),]$season_id

  url <- paste0('http://stats.ncaa.org/team/', team_id, '/stats?game_sport_year_ctl_id=', year_id, '&id=', year_id)

  payload_read <- xml2::read_html(url)

  payload_df <- payload_read %>%
    rvest::html_nodes('table') %>%
    .[2] %>%
    rvest::html_table(fill = TRUE) %>%
    as.data.frame() %>%
    janitor::clean_names()

  payload_df <- payload_df %>%
    dplyr::mutate(across(everything(), ~ifelse(is.na(.x), 0, .x)))

  return(payload_df)
}
