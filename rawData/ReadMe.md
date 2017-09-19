# Raw Data

This directory holds the Kagera data by wave together with the survey instruments
and assorted guides to the data.

Because of size constraints on GitHub you will need set up the data structure yourself. 
This is a one time operation since the raw data should not change after that.
All survey instruments and data can be downloaded from
[http://go.worldbank.org/793WPKOR00](http://go.worldbank.org/793WPKOR00)

The data structure mostly follows the one you get when downloading the data from
the World Bank's microdata website:

COMMUNITY
|-PASS1
|-PASS2
|-PASS3
|-PASS4
ENUMERATION
HEALER
|-PASS3
HLTHFAC
|-pass1
|-pass2
|-pass3
|-pass4
HOUSEHOLD
|-FUQ
|-WAVE1
|-WAVE2
|-WAVE3
|-WAVE4
PRICE
|-pass1
|-pass2
|-pass3
|-pass4
SCHOOL
|-pass1
|-pass2
|-pass3
|-pass4
OtherKageraData

The main difference from the downloaded data is that "raindata.dta" are placed
in the directory "OtherKageraData"
