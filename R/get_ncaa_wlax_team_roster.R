#' Get Team Rosters for Women's Lacrosse
#'
#' @param team_id The unique team id from the NCAA
#' @param year The season for which you want rsoters
#' If you want the 2017-18 season, you would use 2018.
#'
#' @import dplyr
#' @import readr
#' @import rvest
#' @import stringr
#' @return A data frame
#' @export
#'
#' @examples \dontrun{get_ncaa_wlax_team_roster(392, 2019)}

get_ncaa_wlax_team_roster <- function(team_id,
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

  url <- paste0('http://stats.ncaa.org/team/', team_id, '/roster/', year_id)

  payload_read <- xml2::read_html(url)

  payload_df <- payload_read %>%
    rvest::html_nodes('table') %>%
    .[1] %>%
    rvest::html_table(fill = TRUE) %>%
    as.data.frame()

  names(payload_df) <- payload_df[1,]

  payload_df <- payload_df %>%
    janitor::clean_names() %>%
    .[-1,]

  payload_df <- payload_df %>%
    mutate(team = team,
           team_id = team_id,
           year = year,
           conference = conference,
           conference_id = conference_id)

  payload_df <- payload_df %>%
    select(team:conference_id, everything())

  return(payload_df)
}
