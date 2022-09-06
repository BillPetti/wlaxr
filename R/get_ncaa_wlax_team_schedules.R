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

  if (names(payload_df)[1] == "Date") {

    sched_html <- payload_read %>%
      rvest::html_elements("fieldset") %>%
      rvest::html_elements("table")
    sched_1 <- (payload_read %>%
                  rvest::html_elements("fieldset") %>%
                  rvest::html_elements("table")) [[1]] %>%
      rvest::html_elements("tr")
    sched_1 <- sched_1[2:length(sched_1)]
    sched_1 <- sched_1[c(seq(1,length(sched_1),2))]
    sched <- sched_html %>%
      rvest::html_table() %>%
      as.data.frame()
    sched <- sched %>%
      dplyr::filter(.data$Date != "") %>%
      dplyr::select(-dplyr::any_of("Attendance"))
  }else{
    sched_html <- payload_read %>%
      rvest::html_element("td:nth-child(1) > table")
    sched_1 <- (payload_read  %>%
                  rvest::html_element("td:nth-child(1) > table")) %>%
      rvest::html_elements("tr")
    sched_1 <- sched_1[3:length(sched_1)]
    sched <- sched_html %>%
      rvest::html_table() %>%
      as.data.frame()
    colnames(sched) <- c("Date", "Opponent", "Result")
    sched <- sched[3:nrow(sched),]
  }

  sched <- sched %>%
    dplyr::filter(.data$Date != "")

  game_extractor <- function(x){
    data.frame(slug = ifelse(
      is.null(
        (x %>%
           rvest::html_elements("td:nth-child(3)") %>%
           rvest::html_elements("a.skipMask"))),
      NA_character_,
      (x %>%
         rvest::html_elements("td:nth-child(3)") %>%
         rvest::html_elements("a.skipMask")) %>%
        rvest::html_attr("href")
    ))
  }

  slugs <- lapply(sched_1, game_extractor) %>%
    dplyr::bind_rows()

  sched$opponent_slug <- sched_html %>%
    rvest::html_elements("td:nth-child(2)")%>%
    rvest::html_element("a") %>%
    rvest::html_attr("href")

  sched <- dplyr::bind_cols(sched, slugs)
  sched <- sched %>%
    dplyr::filter(!(.data$Result %in% c("Canceled","Ppd"))) %>%
    dplyr::filter(!(.data$Result == ''))

  sched <- sched %>%
    dplyr::mutate(result = stringr::str_extract_all(sched$Result, '[A-Z]', simplify = TRUE)[,1])

  sched <- sched %>%
    dplyr::mutate(goals_for = stringr::str_extract_all(sched$Result, pattern = '[0-9]+', simplify = TRUE)[,1],
                  goals_against = stringr::str_extract_all(sched$Result, pattern = '[0-9]+', simplify = TRUE)[,2])

  sched <- sched %>%
    dplyr::mutate(location = ifelse(grepl('^@.*', sched$Opponent), 'away',
                                    ifelse(!grepl('@', sched$Opponent), 'home', 'neutral'))) %>%
    dplyr::mutate(location = ifelse(Result == "P", 'game postponed', location)) %>%
    dplyr::mutate(location = ifelse(Result == "Ppd", 'game postponed', location)) %>%
    dplyr::mutate(Opponent = ifelse(location == 'neutral', gsub('@.*', '', Opponent), Opponent)) %>%
    dplyr::mutate(Opponent = gsub(pattern = '(?<![A-Z])@[A-Z].*',
                                  replacement = '',
                                  .$Opponent, perl = TRUE)) %>%
    dplyr::mutate(Opponent = gsub('@', '', Opponent)) %>%
    dplyr::mutate(Opponent = stringr::str_trim(Opponent))

  sched <- sched %>%
    dplyr::mutate(Opponent = stringr::str_trim(sched$Opponent)) %>%
    dplyr::mutate(Opponent = gsub('\\(|\\)', '', Opponent))

  sched <- sched %>%
    dplyr::mutate(Opponent = unlist(regmatches(sched$Opponent,
                                               gregexpr(paste0(distinct_teams, collapse = "|"),
                                                        sched$Opponent))))
  sched <- sched %>%
    dplyr::select(-Result) %>%
    janitor::clean_names() %>%
    mutate(team = team,
           conference = conference,
           conference_id = conference_id,
           division = division) %>%
    select(team, conference, conference_id, division, everything())

  return(sched)

}
