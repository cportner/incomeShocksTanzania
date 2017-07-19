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

// Merging in partner education and generate polygyny dummy

preserve
    tempfile tempEdu
    use "`rawDir'/HOUSEHOLD/WAVE1/S5___IND.DTA", clear 
    foreach wave of numlist 2/4 {
        append using "`rawDir'/HOUSEHOLD/WAVE`wave'/S5___IND.DTA"
    }
    keep cluster hh id passage grade
    rename grade sp_grade    // Differentiating partner's education
    rename id spouseid       // Differentiating partner's id 
    sort cluster hh spouseid passage
    save "`tempEdu'"
restore

// Spouseid is not unique across some female, hence the m:1 merge
sort cluster hh spouseid passage
merge m:1 cluster hh spouseid passage using "`tempEdu'"
drop if _merge == 2 // Otherwise there would be duplicates
drop _merge

// Polygyny dummy - needs to be done in two steps
bysort cluster hh spouseid passage: gen nvals = _N // number of wives claiming same husband
gen polygyny = nvals > 1 & spouseid != .
// also need to update the dummy for males since they can only claim one wife
preserve
    tempfile tempPoly
    keep if polygyny
    replace id = spouseid
    keep cluster hh id passage polygyny
    duplicates drop // just need the one observation
    save "`tempPoly'"
restore
merge 1:1 cluster hh id passage using "`tempPoly'", update replace
drop _merge

// Identifying which household members are no longer in the household

preserve
    tempfile tempMoved
    use "`rawDir'/HOUSEHOLD/WAVE1/S1___IND.DTA", clear
    foreach wave of numlist 2/4 {
        append using "`rawDir'/HOUSEHOLD/WAVE`wave'/S1___IND.DTA" 
    }
    keep cluster hh id passage LivnHere hhmbr // keeping only the variables that identify that a person is still in the household
    sort cluster hh id passage
    save "`tempMoved'"
restore
merge 1:1 cluster hh id passage using "`tempMoved'"
drop _merge

// Add survey calculated total income from the surveyors
preserve
    tempfile tempIncome
    use "`rawDir'/OtherKageraData/inc___hh.dta", clear
    sort cluster hh passage
    keep cluster hh passage incagr inchh1 // total agricultural income and total household income
    save "`tempIncome'"
restore
merge m:1 cluster hh passage using "`tempIncome'"
drop _merge


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
