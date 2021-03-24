#' Get Team Stats for Women's Lacrosse
#'
#' @param team_id The unique team id from the NCAA
#' @param year The season for which you want data.
#' If you want the 2017-18 season, you would use 2018.
#'
#' @import dplyr
#' @import readr
#' @import rvest
#' @import stringr
#' @return A data frame
#' @export
#'
#' @examples \dontrun{get_ncaa_wlax_stats(392, 2019)}

get_ncaa_wlax_team_stats <- function(team_id,
                                     year) {

  year_id <- ncaa_stats_year_lu_table[which(ncaa_stats_year_lu_table$season == year),]$season_id

  team <- master_wlax_ncaa_team_lu[which(master_wlax_ncaa_team_lu$school_id == team_id &
                                           master_wlax_ncaa_team_lu$year == year),]$school

  conference <- master_wlax_ncaa_team_lu[which(master_wlax_ncaa_team_lu$school_id == team_id &
                                                 master_wlax_ncaa_team_lu$year == year),]$conference

  conference_id <- master_wlax_ncaa_team_lu[which(master_wlax_ncaa_team_lu$school_id == team_id &
                                                    master_wlax_ncaa_team_lu$year == year),]$conference_id

  division <- master_wlax_ncaa_team_lu[which(master_wlax_ncaa_team_lu$school_id == team_id &
                                               master_wlax_ncaa_team_lu$year == year),]$division

  url <- paste0('http://stats.ncaa.org/team/', team_id, '/stats?game_sport_year_ctl_id=', year_id, '&id=', year_id)

  payload_read <- xml2::read_html(url)

  payload_df <- payload_read %>%
    rvest::html_nodes('table') %>%
    .[2] %>%
    rvest::html_table(fill = TRUE) %>%
    as.data.frame() %>%
    janitor::clean_names()

  payload_df <- payload_df %>%
    dplyr::mutate(team = team,
           conference = conference,
           conference_id = as.character(conference_id),
           division = as.character(division)) %>%
    dplyr::select(team, conference, conference_id, division, everything())

  payload_df <- payload_df %>%
    dplyr::mutate(gp = as.numeric(gp),
                  gs = as.numeric(gs)) %>%
    dplyr::mutate_if(is.numeric, ~ifelse(is.na(.x), 0, .x))

  payload_df <- payload_df %>%
    filter(player != "TEAM")

  return(payload_df)
}
