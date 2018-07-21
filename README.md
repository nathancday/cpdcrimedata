---
updated: "2018/07/21"
version: 0.1.01
---

# cpdcrimedata

This package provides `crime`, a geocoded version of the Charlottesville Police Assistance Report.

```
devtools::install_github("nathancday/cpdcrimedata")
# installs library(tidyverse)
```

## CPD Crime Data

Original report is available on the [Charlottesville Opend Data Portal](http://opendata.charlottesville.org/datasets/crime-data):

>This dataset represents the initial information that is provided by individuals calling for police assistance. Please note that the dataset only contains the last 5 years and excludes homicides, suicides, and sex offenses; aggravated assaults are shown after a four week delay. Remaining information is often amended for accuracy after an Officer arrives and investigates the reported incident.   Most often, the changes are made to more accurately reflect the official legal definition of the crimes reported.  An example of this is for someone to report that they have been “robbed,” when their home was broken into while they were away.  The official definition of “robbery,” is to take something by force.  An unoccupied home being broken into, is actually defined as a “burglary,” or a “breaking and entering.”  While there are mechanisms in place to make each initial call as accurate as possible, some events require evaluation upon arrival.  Caution should be used when making assumptions based solely on the data provided, as they may not represent the official crime reports. 


### Other things

It also contains an accessory dataset, `addresses` of successfully geocoded addresses (in and around Charlottesville, Virginia) that may be useful to another analysis.

Two geocode query tool functions are exported too. `?re_geocode` will automatically reattempt any failed queries in a set. `?extract_geocode` pulls a tibble out of the results `?ggmap::geocode()`.


