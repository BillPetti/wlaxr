% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_ncaa_wlax_team_schedules.R
\name{get_ncaa_wlax_team_schedules}
\alias{get_ncaa_wlax_team_schedules}
\title{Get Team Stats for Women's Lacrosse}
\usage{
get_ncaa_wlax_team_schedules(team_id, year)
}
\arguments{
\item{team_id}{The unique team id from the NCAA}

\item{year}{The season for which you want data.
If you want the 2017-18 season, you would use 2018.}
}
\value{
A data frame
}
\description{
Get Team Stats for Women's Lacrosse
}
\examples{
\dontrun{get_ncaa_wlax_team_schedules(392, 2019)}
}
