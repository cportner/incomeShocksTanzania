// Create base data file
// crBase.do
// Edited: 2017-07-20

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
    keep cluster hh id passage schl grade grd
    rename schl  sp_schl     // Partner ever attended school
    rename grade sp_grade    // Partner's education
    rename grd   sp_grd      // Partner's education
    rename id spouseid       // Partner's id 
    // "grd" is already coded from Karega survey, but seems to miss some no school obs
    gen sp_educ_years = sp_grd
    replace sp_educ_years = 0 if sp_schl == 2 ///
        | sp_grade == "ADULTED" | sp_grade == "*******"  // never attended formal school
    sort cluster hh spouseid passage
    save "`tempEdu'"
restore

// Spouseid is not unique across some female, hence the m:1 merge
sort cluster hh spouseid passage
merge m:1 cluster hh spouseid passage using "`tempEdu'"
drop if _merge == 2 // Otherwise there would be duplicates
drop _merge

// Polygyny dummy - needs to be done in two steps
// This works because only those who report that their spouse live in household show an id for the spouse
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
drop _merge nvals

// Identifying which household members are no longer in the household

preserve
    tempfile tempMoved
    use "`rawDir'/HOUSEHOLD/WAVE1/S1___IND.DTA", clear
    foreach wave of numlist 2/4 {
        append using "`rawDir'/HOUSEHOLD/WAVE`wave'/S1___IND.DTA" 
    }
    keep cluster hh id passage LivnHere hhmbr  // keeping only the variables that identify that a person is still in the household
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

drop if ageyr < 7             // Way too young (move substantial restriction later)
drop if hhmbr == 2            // Not a household member
drop if LivnHere == 2         // Prior household member but not in household this wave
drop if ageyr == . | sex == . // No reason to keep those around - not recorded for people who left the survey

drop hhmbr LivnHere

///////////////////////////////////
// Defining/redefining variables //
///////////////////////////////////

// Unique person and household identifiers
gen id_person = cluster*10000 + hh*100 + id
gen id_hh     = cluster*100 + hh
order id_hh id_person, after(id)

// Period dummies
tab passage, gen(pass)

// Fix age
// use _n instead of wave because some respondents enter our age range later than wave 1.
// this is important if we want to increase number of observations by allowing those
// who are not observed in all waves.
// We just need to get the initial age correct and use that instead of getting every age
// correct and rely on the small changes over time (not enough variation anyway)
// Age difference for 4 survey waves will be between 1 and 2 years. It should not be
// more and it cannot be zero.
// If max and min ages are 1 or 2 years apart for 4 waves then fine, use smallest as 
// initial age.
// For less than 4 waves use corresponding lower difference
bysort id_person: egen medianage = median(ageyr)
bysort id_person: egen agemin = min(ageyr)
bysort id_person: egen agemax = max(ageyr)
bysort id_person: gen numwaves = _N
gen firstage = agemin if (numwaves == 4 | numwaves == 3) ///
    & (agemax - agemin == 2 | agemax - agemin == 1)
replace firstage = agemin if numwaves == 2 & (agemax - agemin == 1 | agemax == agemin)
replace firstage = agemin if numwaves == 1
gen age_problem = firstage == .
replace firstage = int(medianage) if age_problem
// checking how many have age problems
preserve
    // hist ageyr if wave == 1 & numwaves == 4, discrete
    bysort id_person: keep if _n == 1
    tab age_problem
restore
// create age group 
egen agegroup = cut(firstage), at(12,23,28,33,38,50) // last group from 38 to 45 because relatively few in 43-45 age
drop numwaves agemin agemax medianage


// Education (respondent's - partner's come from above)
// "grd" is already coded from Karega survey, but seems to miss some no school obs
// General information on Tanzania's education system: https://www.classbase.com/countries/Tanzania/Education-System
// Also see page 30 of Interviewer's Manual
gen educ_years = grd
replace educ_years = 0 if schl == 2 ///
    | grade == "ADULTED" | grade == "*******"  // never attended formal school


// Contraception use


//////////////////////////////
// Variable labels          //
//////////////////////////////

lab var id_hh         "Unique household identifier"
lab var id_person     "Unique individual identifier"

lab var polygyny      "Polygyny (imputed)"

lab var educ_years    "Education completed in years"
lab var sp_educ_years "Spouse's education in years"

lab var firstage      "Age in first wave (possibly imputed)"
lab var age_problem   "Inconsistency in reported ages"
lab var agegroup      "Age groups based on firstage"




//////////////////////////////
// Save base data set       //
//////////////////////////////

save `dataDir'/base, replace
