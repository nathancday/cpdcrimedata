#' ------
#' title: Crime Data Update
#' description: Pull current version of records from city's open data portal and
#' update package data.
#' ----

### Globals -------------------------------------------------------------
library(geojsonio)
library(ggmap)
library(magrittr)
library(tidyverse)


### Inputs --------------------------------------------------------------

## get current CPD report from ODP
crime_raw <- geojson_read("https://opendata.arcgis.com/datasets/d1877e350fad45d192d233d2b2600156_7.geojson",
                           parse = TRUE) %>%
    .[["features"]] %>%
    .[["properties"]]

if (nrow(crime_raw) == nrow(crime)) {
    stop("Version looks to be most current already!")
} else {
    write_csv(crime_raw, "data-raw/crime_raw.csv")


    ## Previously geo-coded addresses
    addresses_prior <- read_csv("data-raw/addresses.csv")

    ### Clean ---------------------------------------------------------------

    crime_raw %<>% mutate_at(vars(BlockNumber, StreetName), funs(trimws(.))) %>%
        mutate(BlockNumber = as.numeric(BlockNumber) %>%
                   ifelse(is.na(.) | (. == 0), 100, .),
               address = paste(BlockNumber, StreetName, "Charlottesville VA") )

    ### Split --------------------------------------------------------------

    good <- inner_join(crime_raw, addresses)
    bad <- anti_join(crime_raw, addresses)

    ### Geocode bad ------------------------------------------------------

    bad %<>% re_geocode() %>%
        mutate(extracted = map(geocode, extract_geocode)) %>%
        unnest(extracted) %>%
        select(-starts_with("geocode")) %>%
        mutate_at(vars(lat, lon), as.numeric)

    ### Join -------------------------------------------------------------

    crime <- bind_rows(good, bad) %>%
        mutate(DateReported = as.POSIXct(DateReported)) %>%
        arrange(desc(DateReported))

    ### Saves -------------------------------------------------------------

    addresses <- crime %>%
        select(address:loc_type) %>%
        distinct() %>%
        bind_rows(addresses_prior) %>%
        distinct()

    if (nrow(addresses) > nrow(addresses_prior)) {
        use_data(addresses, overwrite = TRUE)
        write_csv(addresses, "data-raw/addresses.csv")
        }

    if (nrow(crime_raw) == nrow(crime)) {
        use_data(crime, overwrite = TRUE)
    }
}



