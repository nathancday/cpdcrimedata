#' ------
#' title: Crime Data Update
#' description: Pull current version of records from city's open data portal and
#' update package data.
#' ----

update <- "2019-09-28" # reflects dataset date of update on ODP

### Globals -------------------------------------------------------------
library(geojsonio)

library(googleway)
set_key(Sys.getenv("GOOGLE_API"))

library(magrittr)
library(tidyverse)

library(devtools)
load_all(".")

### Inputs --------------------------------------------------------------

## get current CPD report from ODP
crime_raw <- geojsonio::geojson_read("https://opendata.arcgis.com/datasets/d1877e350fad45d192d233d2b2600156_6.geojson",
  parse = TRUE
) %>%
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

  crime_raw %<>% mutate_at(vars(BlockNumber, StreetName), ~ trimws(.)) %>%
    mutate(
      BlockNumber = as.numeric(BlockNumber) %>%
        ifelse(is.na(.) | (. == 0), 100, .),
      address = paste(BlockNumber, StreetName, "Charlottesville VA")
    )

  ### Split --------------------------------------------------------------

  good <- inner_join(crime_raw, addresses_prior)
  bad <- anti_join(crime_raw, addresses_prior)

  ### Geocode bad ------------------------------------------------------

  # lots of "bad" addresses are in  "Stree1 / Street2" style
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
