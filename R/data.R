#' CPD Crime Data
#'
#' The last 5 years of requests for police assistance in Charlottesville, Virginia
#' excludeing homicides,
#' suicides, and sex offenses. Sourced from the [opendata.charalottesville.org](http://opendata.charlottesville.org/datasets/crime-data)
#' and geocoded with the GoogleMaps API. Addresses that could not be geocoded, are
#' included with `NA` values in the columns related to geocoding.
#' @md
#' @format A data frame with 13 variables, the first 9 are directly from the
#' the original report, the extra 4 are: `lat`, `lon`, `formatted_address`, and 
#' `loc_type`
"crime"

#' Geocoded addresses to the hundred-block
#'
#' On going list of addresses from the [CPD Crime Reports](http://opendata.charlottesville.org/datasets/crime-data),
#' that have been successfully geocode via GoogleMaps
#' API. BlockNumber values of `0` or `NA` get recoded as `100``, for better accuracy.
#' Useful for saving that query limit.
#' @md
#' @format A data frame with 5 variables: \code{address} (from the original report), \code{lat}, \code{lon} \code{formatted_address} (address returned by API), and
#'   \code{loc_type}. See [Geocoding API](https://developers.google.com/maps/documentation/geocoding/intro)
#'   and `?ggmap::geocode()` for more.
"addresses"
