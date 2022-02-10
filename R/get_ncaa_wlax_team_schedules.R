#' Get Team Stats for Women's Lacrosse
#'
#' @param team_id The unique team id from the NCAA
#' @param year The season for which you want data.
#' If you want the 2017-18 season, you would use 2018.
#'
#' @import dplyr
#' @import tibble
#' @import readr
#' @import rvest
#' @import stringr
#' @return A data frame
#' @export
#'
#' @examples \dontrun{get_ncaa_wlax_team_schedules(392, 2019)}

get_ncaa_wlax_team_schedules <- function(team_id,
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

  url <- paste0('http://stats.ncaa.org/team/', team_id, '/', year_id)

  payload_read <- xml2::read_html(url)

  payload_df <- payload_read %>%
    rvest::html_nodes('table') %>%
    .[2] %>%
    rvest::html_table(fill = TRUE) %>%
    as.data.frame()

  if (year >= 2019) {

    payload_df <- payload_df %>%
      janitor::clean_names() %>%
      dplyr::mutate(date = lubridate::mdy(date)) %>%
      filter(!is.na(date)|date != '')

    payload_df <- payload_df %>%
      dplyr::mutate(attendance = as.character(attendance)) %>%
      dplyr::mutate(attendance = readr::parse_number(attendance))

    box_score_slugs <- payload_read %>%
      rvest::html_nodes('fieldset .skipMask') %>%
      rvest::html_attr('href') %>%
      as.data.frame() %>%
      dplyr::rename(boxscore_url = '.') %>%
      dplyr::mutate(boxscore_url = paste0('http://stats.ncaa.org', boxscore_url)) %>%
      dplyr::filter(grepl('box_score', boxscore_url))

    if(nrow(box_score_slugs) < nrow(payload_df)) {

      joined_boxscores <- payload_df %>%
        mutate(row = row_number()) %>%
        filter(!result %in% c('Ppd', 'Canceled')) %>%
        bind_cols(box_score_slugs) %>%
        select(row, boxscore_url)

      payload_df <- payload_df %>%
        mutate(row = row_number()) %>%
        left_join(joined_boxscores, by = 'row') %>%
        select(-row)

    } else {

      payload_df <- payload_df %>%
        dplyr::mutate(boxscore_url = box_score_slugs$boxscore_url)
    }

  } else {

    names(payload_df) <- payload_df[2,]

    payload_df <- payload_df[-c(1:2),]

    payload_df <- payload_df %>%
      janitor::clean_names() %>%
      dplyr::mutate(date = lubridate::mdy(date))

    payload_df <- payload_df %>%
      dplyr::mutate(attendance = NA) %>%
      dplyr::mutate(attendance = as.numeric(attendance))

  }

  payload_df <- payload_df %>%
    dplyr::mutate(result = stringr::str_extract_all(payload_df$result, '[A-Z]', simplify = TRUE)[,1]) %>%
    dplyr::mutate(goals_for = stringr::str_extract_all(payload_df$result, pattern = '[0-9]+', simplify = TRUE)[,1],
                  goals_against = stringr::str_extract_all(payload_df$result, pattern = '[0-9]+', simplify = TRUE)[,2])

  payload_df <- payload_df %>%
    dplyr::mutate(location = ifelse(grepl('^@.*', payload_df$opponent), 'away',
                                    ifelse(!grepl('@', payload_df$opponent), 'home', 'neutral'))) %>%
    dplyr::mutate(location = ifelse(result == "P", 'game postponed', location)) %>%
    dplyr::mutate(location = ifelse(result == "Ppd", 'game postponed', location)) %>%
    dplyr::mutate(opponent = ifelse(location == 'neutral', gsub('@.*', '', opponent), opponent)) %>%
    dplyr::mutate(opponent = gsub(pattern = '(?<![A-Z])@[A-Z].*',
                                  replacement = '',
                                  .$opponent, perl = TRUE)) %>%
    dplyr::mutate(opponent = gsub('@', '', opponent)) %>%
    dplyr::mutate(opponent = stringr::str_trim(opponent))

  payload_df <- payload_df %>%
    dplyr::mutate(opponent = stringr::str_trim(payload_df$opponent)) %>%
    dplyr::mutate(opponent = gsub('\\(|\\)', '', opponent))

  payload_df <- payload_df %>%
    dplyr::mutate(opponent = unlist(regmatches(payload_df$opponent,
                                               gregexpr(paste0(distinct_teams, collapse = "|"),
                                                        payload_df$opponent))))
  payload_df <- payload_df %>%
    mutate(team = team,
           conference = conference,
           conference_id = conference_id,
           division = division) %>%
    select(team, conference, conference_id, division, everything())

  return(payload_df)
}
