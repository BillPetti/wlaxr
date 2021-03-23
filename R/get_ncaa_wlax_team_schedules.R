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
#' @examples \dontrun{get_ncaa_wlax_team_schedules(392, 2019)}

get_ncaa_wlax_team_schedules <- function(team_id,
                                         year) {

  year_id <- ncaa_stats_year_lu_table[which(ncaa_stats_year_lu_table$season == year),]$season_id

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
      dplyr::mutate(across(everything(), ~ifelse(is.na(.x), 0, .x))) %>%
      dplyr::mutate(attendance = parse_number(attendance))

    box_score_slugs <- schedule_test %>%
      rvest::html_nodes('fieldset .skipMask') %>%
      rvest::html_attr('href') %>%
      as.data.frame() %>%
      dplyr::rename(boxscore_url = '.') %>%
      dplyr::mutate(boxscore_url = paste0('http://stats.ncaa.org/', boxscore_url))

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
                                    ifelse(!grepl('@', payload_df$opponent), 'home',
                                           'neutral'))) %>%
    dplyr::mutate(opponent = gsub(pattern = '(?<![A-Z])@[A-Z].*',
                                  replacement = '',
                                  payload_df$opponent, perl = TRUE)) %>%
    dplyr::mutate(opponent = gsub('@', '', opponent)) %>%
    dplyr::mutate(opponent = stringr::str_trim(opponent))

  payload_df <- payload_df %>%
    dplyr::mutate(opponent = unlist(regmatches(payload_df$opponent,
                                                  gregexpr(paste0(distinct_teams, collapse = "|"),
                                                           payload_df$opponent))))
  return(payload_df)
}
