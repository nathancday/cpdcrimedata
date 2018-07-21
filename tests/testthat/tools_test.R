# ----
# title: Tests for tools.R
# ----


data <- data.frame(address = c("600 E Market St Charlottesville VA",
                               "1200 Emmit St Charlottesville VA"))
result <- re_geocode(data)

expect_is(result, c("data.frame"))

expect_error(re_geocode(mtcars))
