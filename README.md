
<!-- README.md is generated from README.Rmd. Please edit that file -->
cpdcrimedata
============

This package provides `cpd_crime`, a geocoded version of the Charlottesville Police Assistance Report that was uploaded to the Charlottesville OpenData Portal on 2018-08-31.

To install this package from GitHub:

    devtools::install_github("nathancday/cpdcrimedata")

CPD Crime Data
--------------

Original report is available on the [Charlottesville Opend Data Portal](http://opendata.charlottesville.org/datasets/crime-data):

> This dataset represents the initial information that is provided by individuals calling for police assistance. Please note that the dataset only contains the last 5 years and excludes homicides, suicides, and sex offenses; aggravated assaults are shown after a four week delay. Remaining information is often amended for accuracy after an Officer arrives and investigates the reported incident. Most often, the changes are made to more accurately reflect the official legal definition of the crimes reported. An example of this is for someone to report that they have been “robbed,” when their home was broken into while they were away. The official definition of “robbery,” is to take something by force. An unoccupied home being broken into, is actually defined as a “burglary,” or a “breaking and entering.” While there are mechanisms in place to make each initial call as accurate as possible, some events require evaluation upon arrival. Caution should be used when making assumptions based solely on the data provided, as they may not represent the official crime reports.

`cpd_crime` has the original reports 9 columns, plus 4 new ones: \* `formatted_address` - address used in the successful GoogleAPI geocode \* `lat` - lattitude value returned \* `lon` - longitude value returned \* `loc_type` - type of location returned

This dataset is being constantly updated by the city. I try to keep this pacakge in sync but if you see this pacakge is lagging behind please open an issue.

### Other things

An accessory dataset: \* `cville_addresses` with geocoded addresses for 100 block numbers (in and around Charlottesville, Virginia). This is a living list of all of the address this project has seen and succesfully geocoded.
