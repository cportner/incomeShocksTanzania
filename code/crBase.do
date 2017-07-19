// Create base data file
// crBase.do
// Edited: 2017-07-19

vers 13.1
clear

//  short file paths - assuming work directory is "code"
loc rawDir    "../rawData"
loc dataDir   "../data"

//////////////////////////////
// Combining data files     //
//////////////////////////////

// Appending individual wave files to form panel

use `dataDir'/individual_wave1
foreach wave of numlist 2/4 {
    append using `dataDir'/individual_wave`wave'
}
sort cluster hh passage

// Merge in household level information

foreach wave of numlist 1/4 {
    merge m:1 cluster hh passage using `dataDir'/household_wave`wave'
    drop _merge
}


///////////////////////////////////
// Defining/redefining variables //
///////////////////////////////////


//////////////////////////////
// Variable labels          //
//////////////////////////////


//////////////////////////////
// Save base data set       //
//////////////////////////////

save `dataDir'/base, replace
