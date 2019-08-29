# Changelog

## 0.4.6 (Aug 27, 2019)
* Updated out of date gems

## 0.4.4 (May 17, 2014)
* Fixed an issue with downloading data from PG&E.

## 0.4.3 (August 18, 2012)
* Fixed an issue with downloading data from PG&E.

## 0.4.2 (February 9, 2012)
* Fixed an issue with uploading data to pachube.
* Fixed README to accurately reflect the new API.
* Save files with the proper extension (ESPI)

## 0.4.1 (February 5, 2012)
* Fixed an issue with downloading multiple days at the same time.
* Fixed an issue with detecting incomplete data.

## 0.4.0 (January 28, 2012)
* Removed Google PowerMeter as it no longer exists
* Rewrote PG&E scraper to work with OPower, their new web data provider.
* Handle passwords greater than 8 characters.
* Remove spec files from the gem.

## 0.3.3 (April 20, 2011)
* Fixed a bug which prevent the proper Google PowerMeter authentication
  information to be sent.
* Fixed a bug in exception handling to make it a bit more resilient.
* Fixed up some development nitpicks.

## 0.3.2 (March 29, 2011)
* Added support for Brighter Planet's Electricity API.
* Fixed encryption of passwords that had lengths other than multiples of
  8.
* Added more extensive documentation of the library.

## 0.3.1 (March 15th, 2011)
* Changed name from "Smartermeter" to "SmarterMeter"
* Updated the .detect\_charset monkeypatch for the newer mechanize
* Removed unnecessary gems from the Windows package.

## 0.3.0 (March 14th, 2011)
* Added a Windows version of SmarterMeter which runs from the taskbar
  and provides a wizard for easy configuration.
* Upgraded Mechanize to the latest released version.

## 0.2.1 (January 25th, 2011)
* Fixed bugs in the sample parser

## 0.2.0 (January 25th, 2011)
* Abstracted the UI so that a GUI based client could be built.
* Made the fetcher more robust to allow for network errors while transferring
  data.
* Added compatibility with JRuby

## 0.1.0 (January 8th, 2011)
* First public release
