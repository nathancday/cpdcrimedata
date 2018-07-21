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
#' @export
extract_geocode <- function(api_result) {
    if (length(api_result) == 2) {
        if (api_result$status == "OK") {
            res <- api_result$results %>%
                unlist() %>%
                bind_rows() %>%
                select(formatted_address,
                       lat = geometry.location.lat,
                       lon = geometry.location.lng,
                       loc_type = geometry.location_type)
        }
    }
    else { res <- tibble(formatted_address = NA) }

    return(unique(res))
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
#' @export
re_geocode <- function(data, retry = 2) {

    data %<>%
        mutate(address = as.character(address),
               geocode = map(address, ~ggmap::geocode(.,
                                                      source = "google",
                                                      output = "all")),
               geocode_good = map_lgl(geocode, ~.["status"] == "OK"))

    query_count <- nrow(data)

    while (retry > 0 & (sum(data$geocode_good) != nrow(data) ) ) {
        retry <- retry - 1
        query_count <- query_count + sum(!data$geocode_good)
        
        data %<>%
            filter(!geocode_good) %>%
            mutate(geocode = ggmap::geocode(address,
                                            source = "google",
                                            output = "all")) %>%
            bind_rows(filter(data, geocode_good))
    }

    message(cat( (sum(data$geocode_good) / nrow(data))*100, "% of addresses geocoded successfully, using", query_count, "API queries."))
    return(data)
}
