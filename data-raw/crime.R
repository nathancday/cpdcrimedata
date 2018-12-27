#' ------
#' title: Crime Data Update
#' description: Pull current version of records from city's open data portal and
#' update package data.
#' ----

update <- "2018-11-26" # reflects dataset date of update on ODP

### Globals -------------------------------------------------------------
# library(geojsonio)

library(googleway)
set_key(Sys.getenv("GOOGLE_API"))

library(magrittr)
library(tidyverse)

library(devtools)
load_all(".")


# Tools -------------------------------------------------------------------

#' Extract specific fields from full geocode results
#'
#' Pulls four fields ('geometry.location.lat', 'geometry.location.lon',
#' 'geometry.location_type', 'formatted_address') form the Google Maps API result
#' into a tibble.
#'
#' Useful parser to pair down the lengthy JSON object that gets returned
#' @md
#' @param api_result The return value of `ggmap::geocode()`.
#' @return A 1x4 `tibble` with snake_case `names()`.
#' @examples
#' geocode("Lincoln Memorial", "all") %>%
#'   geocode_extract()
extract_geocode <- function(api_result) {
    if (length(api_result) == 2) {
        if (api_result$status == "OK") {
            res <- api_result$results %>%
                unlist() %>%
                bind_rows() %>%
                rename_all(funs(gsub("1$", "", .))) %>% # because some queries return two different addresses (ie. 100 East High St & 100 Little High St)
                select(formatted_address,
                       lat = geometry.location.lat,
                       lon = geometry.location.lng,
                       loc_type = geometry.location_type)
        }
    }
    else { res <- tibble(formatted_address = NA) }
    
    unique(res)
}

#' Repeat failed Google Maps API queries
#'
#' A persistant function that re-attempts failed address geocode queries, a set # of times or until all
#' queries are succesfully.
#' @md
#' @param data A data frame with a column named 'address'
#' @param retry An integer for the number of times to re-attempt addresses that
#' failted to properly geocode.
#' @return The original data frame with new columns 'geocode', a list, of raw API
#' query results, and 'geocode_good', a boolean, `TRUE` if successful.
re_geocode <- function(.data, retry = 2) {
    
    .data %<>%
        mutate(address = as.character(address),
               geocode = map(address, googleway::google_geocode),
               geocode_good = map_lgl(geocode, ~.["status"] == "OK"))
    
    query_count <- nrow(.data)
    
    while ( sum(.data$geocode_good) != nrow(.data)  &&
             retry > 0 )  {
        
        retry <- retry - 1
        query_count <- query_count + sum(!.data$geocode_good)
        
        .data %>%
            filter(!geocode_good) %>%
            mutate(geocode = googleway::google_geocode) %>%
            bind_rows(filter(.data, geocode_good))
    }
    
    message(cat( (sum(.data$geocode_good) / nrow(.data))*100, "% of addresses geocoded successfully, using", query_count, "API queries."))
    return(.data)
}

### Inputs --------------------------------------------------------------

## get current CPD report from ODP
crime_raw <- geojsonio::geojson_read("https://opendata.arcgis.com/datasets/d1877e350fad45d192d233d2b2600156_6.geojson",
                           parse = TRUE) %>%
    .[["features"]] %>%
    .[["properties"]]

last_version <- dir("data-raw", "address", full.names = TRUE) %>%
    sort(decreasing = TRUE) %>%
    .[1]

if (nrow(crime_raw) == nrow(cpd_crime)) {
    stop("Version looks to be most current already!")
} else {
    
    write_csv(crime_raw, paste0("data-raw/crime_raw_", update, ".csv"))

    ## Previously geo-coded addresses
    addresses_prior <- read_csv(last_version)

    ### Clean ---------------------------------------------------------------

    crime_raw %<>% mutate_at(vars(BlockNumber, StreetName), funs(trimws(.))) %>%
        mutate(BlockNumber = as.numeric(BlockNumber) %>%
                   ifelse(is.na(.) | (. == 0), 100, .),
               address = paste(BlockNumber, StreetName, "Charlottesville VA") )

    ### Split --------------------------------------------------------------

    good <- inner_join(crime_raw, addresses_prior)
    bad <- anti_join(crime_raw, addresses_prior)

    ### Geocode bad ------------------------------------------------------
    
    # lots of "bad" addresses arein  "Stree1 / Street2" style
    bad$address %<>% gsub("[/@].*", "Charlotesville VA", .)

    bad %<>% re_geocode()
    bad %<>%
        mutate(extracted = map(geocode, possibly(extract_geocode, NA))) %>%
        unnest(extracted) %>%
        select(-starts_with("geocode")) %>%
        mutate_at(vars(lat, lon), as.numeric)

    ### Join -------------------------------------------------------------

    cpd_crime <- bind_rows(good, bad) %>%
        mutate(DateReported = as.POSIXct(DateReported)) %>%
        arrange(desc(DateReported))

    ### Saves -------------------------------------------------------------

    cville_addresses <- cpd_crime %>%
        select(address:loc_type) %>%
        distinct() %>%
        bind_rows(addresses_prior) %>%
        distinct()

    if (nrow(cville_addresses) > nrow(addresses_prior)) {
        use_data(cville_addresses, overwrite = TRUE)
        write_csv(cville_addresses, paste0("data-raw/cville_addresses_", update, ".csv"))
        }

    if (nrow(crime_raw) == nrow(cpd_crime)) {
        use_data(cpd_crime, overwrite = TRUE)
    }
}
