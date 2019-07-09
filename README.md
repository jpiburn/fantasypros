
<!-- README.md is generated from README.Rmd. Please edit that file -->

# fantasypros

<!-- badges: start -->

<!-- badges: end -->

The goal of fantasypros is to …

## Installation

You can install the released version of fantasypros from
[CRAN](https://CRAN.R-project.org) with:

``` r
# not on CRAN
install.packages("fantasypros")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("jpiburn/fantasypros")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(fantasypros)

fp_snaps(season = 2018)
#> # A tibble: 505 x 23
#>    player pos   team  season    w1    w2    w3    w4    w5    w6    w7
#>    <chr>  <chr> <chr>  <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1 Aaron~ QB    GB      2018    46    77    69    76    81    71    NA
#>  2 Adria~ RB    WAS     2018    42    25    32    NA    13    37    34
#>  3 Alex ~ QB    WAS     2018    79    74    61    NA    61    70    60
#>  4 Ben R~ QB    PIT     2018    84    82    66    62    60    73    NA
#>  5 Benja~ TE    NE      2018    51    54    45    37    36     0    36
#>  6 Brian~ QB    NE      2018     0     0     0     4     0     0     0
#>  7 Chad ~ QB    KC      2018     0     0     0     0     0     0     0
#>  8 Chase~ QB    CHI     2018     0     0     0     3    NA     0     1
#>  9 Danny~ WR    DET     2018    45    44    31    42    53    75    55
#> 10 Delan~ TE    TEN     2018    39     0     0     0     0     0     0
#> # ... with 495 more rows, and 12 more variables: w8 <dbl>, w9 <dbl>,
#> #   w10 <dbl>, w11 <dbl>, w12 <dbl>, w13 <dbl>, w14 <dbl>, w15 <dbl>,
#> #   w16 <dbl>, w17 <dbl>, ttl <dbl>, avg <dbl>

fp_snaps(pos = "defense", season = 2018, percentage = TRUE)
#> # A tibble: 769 x 23
#>    player pos   team  season    w1    w2    w3    w4    w5    w6    w7
#>    <chr>  <chr> <chr>  <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1 Patri~ CB    ARI     2018    99   100    99    98    97   100    98
#>  2 Adria~ DE    ATL     2018    30    30    42    37    51    33    40
#>  3 Princ~ CB    CHI     2018    98   100    50     0    NA    67    98
#>  4 Marce~ DT    JAC     2018    65    75    68    57    66    60    53
#>  5 Camer~ DE    PIT     2018    85    86    73    74    71    80    NA
#>  6 Von M~ LB    DEN     2018    88    77    68    68    74    70    85
#>  7 Rober~ DE    DAL     2018    59    51    71    56    68    71    58
#>  8 J.J. ~ DE    HOU     2018    93   100    84    87    90    87    90
#>  9 Justi~ DE    IND     2018    77    85    94    97    27     0     0
#> 10 Ryan ~ LB    WAS     2018    68    82    83    NA    73    80    74
#> # ... with 759 more rows, and 12 more variables: w8 <dbl>, w9 <dbl>,
#> #   w10 <dbl>, w11 <dbl>, w12 <dbl>, w13 <dbl>, w14 <dbl>, w15 <dbl>,
#> #   w16 <dbl>, w17 <dbl>, ttl <dbl>, avg <dbl>
```
