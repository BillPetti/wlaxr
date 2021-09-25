
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `wlaxr` 0.2.0

`wlaxr` is an R package built to make acquiring NCAA Women’s Lacrosse
data simple.

You can install the package via:

``` r
library(devtools)	

devtools::install_github("BillPetti/wlaxr")
```

## Functions

Currently, the package contains three functions:

`get_ncaa_wlax_team_schedules()`: used to acquire game schedule and
results for a team in a given year.

`get_ncaaa_wlax_team_stats()`: used to acquire individual- and
team-level stats for a team in a given year.

Both of these functions should work on seasons back to 2001-2002.

`school_lu()`: used to quickly lookup school IDs and other information.

## Data

The package contains a few internal data sets to make the user’s life
easier.

`master_wlax_ncaa_team_lu`: A data frame that includes school name, ID,
conference, conference ID, and division by year. Goes back to 2010.
Please note that there are likely some errors where the NCAA has teams
listed as either in two divisions or, due to being an Indepedent team,
they will appear to be in all three divisions in a single season. I’ve
tried to minimize this by restricting the data to 2010-present, but
there are still some duplicates.

`ncaa_stats_year_lu_table`: A helper data set that contains the season
codes used by the NCAA

## Usage

First, let’s say you are interested in The University of Maryland. You
can use the `school_lu` function to find their NCAA stats ID:

``` r
school_lu(school_name = 'Maryland',
          school_division = 1)
#>             school school_id year division conference_id conference
#> 1  Loyola Maryland       369 2010        1           823        AAC
#> 2         Maryland       392 2010        1           821        ACC
#> 3  Loyola Maryland       369 2011        1           823        AAC
#> 4         Maryland       392 2011        1           821        ACC
#> 5  Loyola Maryland       369 2012        1           823        AAC
#> 6         Maryland       392 2012        1           821        ACC
#> 7  Loyola Maryland       369 2013        1           823        AAC
#> 8         Maryland       392 2013        1           821        ACC
#> 9         Maryland       392 2014        1           821        ACC
#> 10 Loyola Maryland       369 2014        1           838    Patriot
#> 11        Maryland       392 2015        1           827    Big Ten
#> 12 Loyola Maryland       369 2015        1           838    Patriot
#> 13        Maryland       392 2016        1           827    Big Ten
#> 14 Loyola Maryland       369 2016        1           838    Patriot
#> 15        Maryland       392 2017        1           827    Big Ten
#> 16 Loyola Maryland       369 2017        1           838    Patriot
#> 17        Maryland       392 2018        1           827    Big Ten
#> 18 Loyola Maryland       369 2018        1           838    Patriot
#> 19        Maryland       392 2019        1           827    Big Ten
#> 20 Loyola Maryland       369 2019        1           838    Patriot
#> 21        Maryland       392 2020        1           827    Big Ten
#> 22 Loyola Maryland       369 2020        1           838    Patriot
#> 23        Maryland       392 2021        1           827    Big Ten
#> 24 Loyola Maryland       369 2021        1           838    Patriot
```

This returns all records in the `master_wlax_ncaa_team_lu` data set
where ‘Mayrland’ is in the school name and the teams are listed in
division 1. You can see that Maryland has switched conferences over the
years from the ACC to the Big Ten. We also see that Maryland’s
`school_id` is 392. We’ll need that `school_id` for the rest of the
functions.

Next, let’s acquire Maryland’s schedule for the 2019 season when they
won the National Championship:

``` r
md_2019 <- get_ncaa_wlax_team_schedules(team_id = 392, 
                                        year = 2019)

md_2019
#>        team conference conference_id division       date       opponent result
#> 1  Maryland    Big Ten           827        1 2019-02-09   George Mason      W
#> 2  Maryland    Big Ten           827        1 2019-02-14        Florida      W
#> 3  Maryland    Big Ten           827        1 2019-02-24 North Carolina      W
#> 4  Maryland    Big Ten           827        1 2019-02-27           UMBC      W
#> 5  Maryland    Big Ten           827        1 2019-03-02        Hofstra      W
#> 6  Maryland    Big Ten           827        1 2019-03-09       Syracuse      W
#> 7  Maryland    Big Ten           827        1 2019-03-13           Penn      W
#> 8  Maryland    Big Ten           827        1 2019-03-16       Ohio St.      W
#> 9  Maryland    Big Ten           827        1 2019-03-21       Penn St.      W
#> 10 Maryland    Big Ten           827        1 2019-03-24  James Madison      W
#> 11 Maryland    Big Ten           827        1 2019-03-27      Princeton      W
#> 12 Maryland    Big Ten           827        1 2019-03-30        Rutgers      W
#> 13 Maryland    Big Ten           827        1 2019-04-03       Virginia      W
#> 14 Maryland    Big Ten           827        1 2019-04-06       Michigan      W
#> 15 Maryland    Big Ten           827        1 2019-04-11   Northwestern      W
#> 16 Maryland    Big Ten           827        1 2019-04-17     Georgetown      W
#> 17 Maryland    Big Ten           827        1 2019-04-27  Johns Hopkins      W
#> 18 Maryland    Big Ten           827        1 2019-05-03       Penn St.      W
#> 19 Maryland    Big Ten           827        1 2019-05-05   Northwestern      L
#> 20 Maryland    Big Ten           827        1 2019-05-12    Stony Brook      W
#> 21 Maryland    Big Ten           827        1 2019-05-18         Denver      W
#> 22 Maryland    Big Ten           827        1 2019-05-24   Northwestern      W
#> 23 Maryland    Big Ten           827        1 2019-05-26 Boston College      W
#>    attendance goals_for goals_against location
#> 1        2105        16             5     home
#> 2         574        17            12     away
#> 3        3696        13            12     home
#> 4        1128        18             1     away
#> 5        1208        17             9     away
#> 6        1734        12            11     home
#> 7         981        14             9     home
#> 8        1216        16             1     home
#> 9         318        17             6     away
#> 10        804        18             5     away
#> 11       1058        15             7     home
#> 12       1294        20             3     away
#> 13        529        16             6     away
#> 14       6540        14             3     home
#> 15        926        17            13     away
#> 16        577        17             8     away
#> 17       1968        19            12     home
#> 18          0        15             8  neutral
#> 19          0        11            16  neutral
#> 20        311        17             8     home
#> 21       1049        17             8     home
#> 22       8508        25            13  neutral
#> 23       9433        12            10  neutral
```

The function returns a data frame with information about each game
played in that season, including opponents, goals for and against, and
whether the game was played at home, away, or a neutral site.

Let’s say we are interested in Maryland’s player stats for that season:

``` r
md_stats_2019 <- get_ncaa_wlax_team_stats(team_id = 392, 
                                          year = 2019)

md_stats_2019
#>        team conference conference_id division jersey               player yr
#> 1  Maryland    Big Ten           827        1     28      Warther, Hannah Jr
#> 2  Maryland    Big Ten           827        1     22       Griffin, Grace So
#> 3  Maryland    Big Ten           827        1     25       Colson, Lizzie Jr
#> 4  Maryland    Big Ten           827        1     16      Hartshorn, Kali Jr
#> 5  Maryland    Big Ten           827        1      1      Griffin, Brindi Jr
#> 6  Maryland    Big Ten           827        1     34        Taylor, Megan Sr
#> 7  Maryland    Big Ten           827        1     24         Braig, Julia Sr
#> 8  Maryland    Big Ten           827        1      6      Doherty, Meghan Jr
#> 9  Maryland    Big Ten           827        1      5           Giles, Jen Sr
#> 10 Maryland    Big Ten           827        1     33         Evans, Erica Sr
#> 11 Maryland    Big Ten           827        1      2       Mercer, Shelby Sr
#> 12 Maryland    Big Ten           827        1      7           May, Catie So
#> 13 Maryland    Big Ten           827        1     37     Siverson, Meghan Sr
#> 14 Maryland    Big Ten           827        1      9    Donoghue, Marissa Sr
#> 15 Maryland    Big Ten           827        1     11     Steele, Caroline Sr
#> 16 Maryland    Big Ten           827        1     23       Glaros, Hannah Fr
#> 17 Maryland    Big Ten           827        1     12     Cummings, Kelsey Sr
#> 18 Maryland    Big Ten           827        1     20       Hoffman, Julia Fr
#> 19 Maryland    Big Ten           827        1     10    Renehan, Courtney So
#> 20 Maryland    Big Ten           827        1     36      McSally, Maddie Fr
#> 21 Maryland    Big Ten           827        1     14       Barretta, Tori So
#> 22 Maryland    Big Ten           827        1      4  Golladay, Katherine Sr
#> 23 Maryland    Big Ten           827        1     19         Welsh, Darby Fr
#> 24 Maryland    Big Ten           827        1     15       Bracey, Laurie So
#> 25 Maryland    Big Ten           827        1     17      Robbins, Brooke So
#> 26 Maryland    Big Ten           827        1     13        Sliwak, Nikki Jr
#> 27 Maryland    Big Ten           827        1     30         Davis, Kylie So
#> 28 Maryland    Big Ten           827        1      3      Sanchez, Maddie Fr
#> 29 Maryland    Big Ten           827        1     27      Miller, Natalie Jr
#> 30 Maryland    Big Ten           827        1     32        Hine, Madison So
#> 31 Maryland    Big Ten           827        1     18    McTaggart, Andrea Jr
#> 32 Maryland    Big Ten           827        1      8      Salandra, Julia Jr
#> 33 Maryland    Big Ten           827        1     35          Ayer, Sarah Fr
#> 34 Maryland    Big Ten           827        1     44       Lynch, Kennedy Fr
#> 35 Maryland    Big Ten           827        1     29 L'Insalata, Victoria Jr
#> 36 Maryland    Big Ten           827        1      -               Totals  -
#> 37 Maryland    Big Ten           827        1      -      Opponent Totals  -
#>    pos gp gs games fouls gs_1 goals assists points shots shot_pct sog sog_pct
#> 1      23  0    23    12    0    12       3     15    44    0.273  32   0.727
#> 2      23 22    23    20   22    45      12     57    81    0.556  64   0.790
#> 3      23 22    23    59   22     1       1      2     2    0.500   2   1.000
#> 4      23 23    23    37   23    48      19     67   110    0.436  80   0.727
#> 5      23 22    23    13   22    44      24     68    83    0.530  73   0.880
#> 6      23 23    23     0   23     0       0      0     0    0.000   0   0.000
#> 7      23 23    23    25   23     1       0      1     1    1.000   1   1.000
#> 8      23 23    23    17   23     0       0      0     0    0.000   0   0.000
#> 9      23 23    23    26   23    59      23     82   127    0.465  92   0.724
#> 10     23 23    23    24   23    59      15     74   104    0.567  89   0.856
#> 11     23 23    23    23   23     0       1      1     0    0.000   0   0.000
#> 12     22 11    22    11   11    13      14     27    27    0.481  21   0.778
#> 13     21 16    21    14   16    18       4     22    47    0.383  36   0.766
#> 14     20  1    20     5    1     0       0      0     0    0.000   0   0.000
#> 15     20 19    20    14   19    53      17     70   119    0.445  88   0.739
#> 16     12  0    12     3    0     4       1      5     7    0.571   7   1.000
#> 17     10  1    10     2    1     3       1      4     8    0.375   7   0.875
#> 18      9  0     9     1    0     6       3      9    12    0.500  10   0.833
#> 19      7  0     7     0    0     0       0      0     2    0.000   0   0.000
#> 20      7  0     7     0    0     0       0      0     0    0.000   0   0.000
#> 21      7  0     7     3    0     0       0      0     0    0.000   0   0.000
#> 22      6  1     6     0    1     0       0      0     0    0.000   0   0.000
#> 23      6  0     6     0    0     3       0      3     3    1.000   3   1.000
#> 24      6  0     6     0    0     0       0      0     0    0.000   0   0.000
#> 25      5  0     5     1    0     0       0      0     1    0.000   0   0.000
#> 26      4  0     4     0    0     1       0      1     2    0.500   2   1.000
#> 27      4  0     4     1    0     3       0      3     6    0.500   3   0.500
#> 28      3  0     3     0    0     0       0      0     0    0.000   0   0.000
#> 29      3  0     3     1    0     0       0      0     0    0.000   0   0.000
#> 30      3  0     3     0    0     0       0      0     0    0.000   0   0.000
#> 31      3  0     3     0    0     0       0      0     0    0.000   0   0.000
#> 32      2  0     2     0    0     0       0      0     0    0.000   0   0.000
#> 33      2  0     2     0    0     0       0      0     0    0.000   0   0.000
#> 34      1  0     1     0    0     0       0      0     0    0.000   0   0.000
#> 35      1  0     1     0    0     0       0      0     0    0.000   0   0.000
#> 36   -  0  0    23   372    0   373     138    511   786    0.475 610   0.776
#> 37   -  0  0    23   525    0   186      67    253   590    0.315 422   0.715
#>    gwg ppg shg ground_balls  ct ggp ggs   g_min goals_allowed    gaa saves
#> 1    0   1   0            6   3   0   0                     0  0.000     0
#> 2    4   3   0           27  14   0   0                     0  0.000     0
#> 3    0   0   0           46  25   0   0                     0  0.000     0
#> 4    1   5   0           11   8   0   0                     0  0.000     0
#> 5    3   3   0           19   2   0   0                     0  0.000     0
#> 6    0   0   0           25   3  23  23 1257:47           177  8.443   217
#> 7    0   0   0           30  27   0   0                     0  0.000     0
#> 8    0   0   0           22  17   0   0                     0  0.000     0
#> 9    2   5   0           37  14   0   0                     0  0.000     0
#> 10   5   5   0           23   5   0   0                     0  0.000     0
#> 11   0   0   0           31  18   0   0                     0  0.000     0
#> 12   0   0   0           14   4   0   0                     0  0.000     0
#> 13   2   4   0           10   4   0   0                     0  0.000     0
#> 14   0   0   0            5   4   0   0                     0  0.000     0
#> 15   5   7   0           20   6   0   0                     0  0.000     0
#> 16   0   0   0            2   1   0   0                     0  0.000     0
#> 17   0   0   0            2   1   0   0                     0  0.000     0
#> 18   0   0   0            4   2   0   0                     0  0.000     0
#> 19   0   0   0            0   0   0   0                     0  0.000     0
#> 20   0   0   0            1   0   7   0  115:23             8  4.160    16
#> 21   0   0   0            0   0   0   0                     0  0.000     0
#> 22   0   0   0            0   0   0   0                     0  0.000     0
#> 23   0   0   0            0   0   0   0                     0  0.000     0
#> 24   0   0   0            3   1   0   0                     0  0.000     0
#> 25   0   0   0            2   2   0   0                     0  0.000     0
#> 26   0   0   0            1   0   0   0                     0  0.000     0
#> 27   0   0   0            1   0   0   0                     0  0.000     0
#> 28   0   0   0            0   0   0   0                     0  0.000     0
#> 29   0   0   0            1   0   0   0                     0  0.000     0
#> 30   0   0   0            1   0   2   0   17:15             0  0.000     3
#> 31   0   0   0            0   0   0   0                     0  0.000     0
#> 32   0   0   0            0   0   0   0                     0  0.000     0
#> 33   0   0   0            0   0   0   0                     0  0.000     0
#> 34   0   0   0            0   0   0   0                     0  0.000     0
#> 35   0   0   0            1   1   0   0                     0  0.000     0
#> 36  22  33   0          345 162   0   0 1391:30           186  8.020   236
#> 37   1   5   4          299 132   0   0 1391:30           373 16.083   237
#>    save_pct  t rc yc draw_controls clears clr_att
#> 1     0.000 NA NA  1             5      0       0
#> 2     0.000 NA NA  1             3      0       0
#> 3     0.000 NA NA  3           127      0       0
#> 4     0.000 NA NA  4           137      0       0
#> 5     0.000 NA NA  1             1      0       0
#> 6     0.551 NA NA  0             0      0       0
#> 7     0.000 NA NA  5             2      0       0
#> 8     0.000 NA NA  2             1      0       0
#> 9     0.000 NA NA  2            25      0       0
#> 10    0.000 NA NA  0            12      0       0
#> 11    0.000 NA NA  2             0      0       0
#> 12    0.000 NA NA  0             2      0       0
#> 13    0.000 NA NA  1            15      0       0
#> 14    0.000 NA NA  0             0      0       0
#> 15    0.000 NA NA  2             3      0       0
#> 16    0.000 NA NA  0             3      0       0
#> 17    0.000 NA NA  0             2      0       0
#> 18    0.000 NA NA  0             0      0       0
#> 19    0.000 NA NA  0             0      0       0
#> 20    0.667 NA NA  0             0      0       0
#> 21    0.000 NA NA  0             0      0       0
#> 22    0.000 NA NA  0             0      0       0
#> 23    0.000 NA NA  0             2      0       0
#> 24    0.000 NA NA  0             0      0       0
#> 25    0.000 NA NA  0             1      0       0
#> 26    0.000 NA NA  0             0      0       0
#> 27    0.000 NA NA  0             0      0       0
#> 28    0.000 NA NA  0             0      0       0
#> 29    0.000 NA NA  0             0      0       0
#> 30    1.000 NA NA  0             0      0       0
#> 31    0.000 NA NA  0             0      0       0
#> 32    0.000 NA NA  0             0      0       0
#> 33    0.000 NA NA  0             0      0       0
#> 34    0.000 NA NA  0             0      0       0
#> 35    0.000 NA NA  0             0      0       0
#> 36    0.559 NA NA 24           343    407     435
#> 37    0.389 NA NA 64           259    350     403
```

The function returns a data frame with each individual player, their
class, number, etc., and their individual statistics tracked by the
NCAA. There are also team and opponent totals.
