context("tools functional")

data <- data.frame(address = c("600 E Market St Charlottesville VA",
                               "1200 Emmit St Charlottesville VA"))

result <- suppressMessages(re_geocode(data))
expect_is(result, c("data.frame"))
expect_equivalent(nrow(result), 2)
expect_equivalent(ncol(result), 3)
expect_true( all(names(result) %in% c("address", "geocode","geocode_good") ) )

lat_lon <- result$geocode %>%
    map_df(extract_geocode)

expect_is(lat_lon, "data.frame")
expect_equivalent(nrow(lat_lon), 2)
expect_equivalent(ncol(lat_lon), 4)
expect_true( all(names(lat_lon) %in% c("formatted_address", "lat", "lon", "loc_type") ) )

# bad 'data' arguments
expect_error(re_geocode(mtcars))
expect_error(re_geocode(data[1,]))
expect_error(re_geocode(NULL))

