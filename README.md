
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
```

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

``` r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date.

You can also embed plots, for example:

<img src="man/figures/README-pressure-1.png" width="100%" />

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub\!
