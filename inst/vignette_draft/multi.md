## Adjusting multiple series

Since 1.8, it possible to seasonally adjust multiple series in a single call to `seas()`, and also benefit from the *composite* spec.

### Basics

Multiple adjustments can be performed by supplying multiple time series as an
`"mts"` time series object:

```r
m <- seas(cbind(fdeaths, mdeaths), x11 = "")
final(m)
```

This will perform two seasonal adjustments, one for `fdeaths` and one for
`mdeaths`. X13 spec argument combinations can be applied in the usual way, such
as `x11 = ""`. Note that if entered that way, they will apply to all
adjustments.


### Specifying the specs


As in a single series call, we can also use the `list` argument:

```r
seas(cbind(fdeaths, mdeaths), list = list(x11 = ""))
```

It is possible to specify individual specs for each series, by encapsulating
specific spec lists in the `list` argument. In the following, `fdeaths` is
adjusted by X-11 and `mdeaths` by the default SEATS procedure. The length of
list must be equal to number of series.

```r
seas(
  cbind(fdeaths, mdeaths),
  list = list(
    list(x11 = ""),
    list()
  )
)
```

We can also combine these ideas. The following applies turns off the regression
AIC test for all series (`regression.aictest = NULL`) and uses X-11 to adjust
`fdeaths` and SEATS to adjust `mdeaths`:

```r
seas(
  cbind(fdeaths, mdeaths),
  regression.aictest = NULL,
  list = list(
    list(x11 = ""),
    list()
  )
)
```

### Specifying the series

There are multiple ways of specifying the series, too. We already saw how `mts`
objects can be used as an input. Alternatively we can also use a list of single
`"ts"` objects:

```r
seas(list(mdeaths, AirPassengers))
```

This is more convenient if series are of different length or frequency. With the
the *tsbox* package, you can create these kind of time series list from any time
series object. Let's say your data is in a data frame

```r
library(tsbox)
dta <- ts_c(mdeaths = ts_df(mdeaths), AirPassengers = ts_df(AirPassengers))
head(dta)
```

In order to seasonally adjust all series, you can run:

```r
seas(ts_tslist(dta))
```

Finally, you can specify the data directly in the list:

```r
seas(
  list = list(
    list(x = mdeaths, x11 = ""),
    list(x = fdeaths)
  )
)
```

### Backend

X-13 comes with a batch mode that allows multiple adjustments with a single call
to X-13. Alternatively, a separate call for each series can be performed
(`multimode = "R"`). The results should be usually the same, but switching to
`multimode = "R"` may be useful for debugging:

```r
seas(cbind(fdeaths, mdeaths), multimode = "x13")
seas(cbind(fdeaths, mdeaths), multimode = "R")
```

In general, `multimode = "x13"` should be faster. The following comparison shows
a modest speed gain, but bigger differences have been observed on other systems:

```r
many <- rep(list(fdeaths), 100)
system.time(seas(many, multimode = "x13"))
#   user  system elapsed
#  9.415   0.653  10.079
system.time(seas(many, multimode = "R"))
#   user  system elapsed
# 11.130   1.039  12.324
```


### composite spec

Support for the X-13 batch mode makes it finally possible to use the *composite*
spec -- the one missing feature of X-13. Sometimes, one has to decide whether
seasonal adjustment should be performed on a granular level, or on an aggregated
one. The *composite* spec helps you to analyze the problem and to compare the
direct and the indirect adjustment.

X-13 requires to define a `series.comptype` for individual series. Usually, this
will be set to `series.comptype = "add"`. (In principle, this could be defined
as a default, but since this is very new, I will wait with that.).

The `composite` argument is a list with an X-13 specification that is applied on
the aggregated series. Specification works identical as for other series in
`seas()`, including the application of the defaults. If you provide and empty
list, the usual defaults of `seas()` will be used.
A minimal call looks like this:

```r
seas(
  cbind(mdeaths, fdeaths),
  composite = list(),
  series.comptype = "add"
)
```

You can verify that the composite refers to the total of the two series by
running:

```r
seas(ldeaths)
```

