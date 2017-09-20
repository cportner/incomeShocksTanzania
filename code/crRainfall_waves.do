// test version for combining household and rainfall
// crRainTest.do

vers 13.1
clear

//  short file paths - assuming work directory is "code"
loc rawDir    "../rawData"
loc dataDir   "../data"

tempfile surveyDate district rainfall
tempvar newCluster  newDistrict

// cluster district information
use "`rawDir'/ENUMERATION/ENUM_VLG.DTA", clear
keep if insample
keep cluster district
// There are 49 PSU and 51 clusters of households
// cluster 44 should be attributed to cluster 45
// cluster 46 should be attributed to cluster 47
// See User Guide pp 51-52
expand 2 if cluster == 44 | cluster == 46, generate(`newCluster')
replace cluster = 45 if cluster == 44 & `newCluster'
replace cluster = 47 if cluster == 46 & `newCluster'
sort cluster district
drop `newCluster'
save `district'


// Rainfall data
use "`rawDir'/OtherKageraData/raindata.dta", clear
// Note: all dates are 15th of month.
// Bukoba has both a rural and urban part; use rural and then duplicate to form urban
rename bukoba   rainfall2
rename muleba   rainfall3
rename karagwe  rainfall1
rename ngara    rainfall5
rename biharamu rainfall4
drop year month
reshape long rainfall , i(date) j(district)
reshape wide rainfall , i(district) j(date)
expand 2 if district == 2, generate(`newDistrict')
replace district = 6 if `newDistrict'
sort district
drop `newDistrict'
save `rainfall'


foreach wave of numlist 1/4 {
    
    // household survey dates
    use "`rawDir'/HOUSEHOLD/WAVE`wave'/S_____HH.DTA", clear
    keep cluster-int1yr
    drop int1 
    drop if int1yr == .

    // Merging district identifier
    sort cluster hh wave
    merge m:1 cluster using `district'
    drop _merge

    // Merging rainfall data
    sort district
    merge m:1 district using `rainfall'
    drop _merge
    
    // Save rainfall data for wave
    save "`dataDir'/rainfall_wave`wave'.dta", replace

}

exit




Use bukoba = 2 for rural

. tab district 

       1988 |
    Census: |
   District |
     number |      Freq.     Percent        Cum.
------------+-----------------------------------
    KARAGWE |          5        9.62        9.62
   BUKOBA_R |         18       34.62       44.23
     MULEBA |          9       17.31       61.54
   BIHARAMU |          4        7.69       69.23
      NGARA |          6       11.54       80.77
   BUKOBA_U |         10       19.23      100.00
------------+-----------------------------------
      Total |         52      100.00

. tab district , nol

       1988 |
    Census: |
   District |
     number |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |          5        9.62        9.62
          2 |         18       34.62       44.23
          3 |          9       17.31       61.54
          4 |          4        7.69       69.23
          5 |          6       11.54       80.77
          6 |         10       19.23      100.00
------------+-----------------------------------
      Total |         52      100.00


