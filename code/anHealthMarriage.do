// Health and marriage results
// anHealthMarriage.do

vers 13.1
clear
file close _all // makes working on code easier

//  short file paths - assuming work directory is "code"
loc data   "../data"
loc tables    "../tables"

use `data'/base

xtset id_person


keep if female 
drop if nonconsecutive

tempvar min_age max_age 

by id_person: egen `min_age' = min(ageyr)
drop if `min_age' < 18
by id_person: egen `max_age' = max(ageyr)
drop if `max_age' > 45

// drop if any missing marriage status or if widowed in current or prior periods
tempvar miss_marstat widow everwidowed
by id_person: egen `miss_marstat' = count(marstat)
by id_person: drop if `miss_marstat' < _N

gen `everwidowed' = .
gen `widow' = marstat == 5
replace `everwidowed' = `widow' == 1 if wave == 1
foreach wave of numlist 2/4 {
    by id_person (wave): replace `everwidowed' = `widow' == 1 | `everwidowed'[_n-1] == 1 if wave == `wave'
}
drop if `everwidowed' == 1


/////////////////////////////////
// Recode and create variables //
/////////////////////////////////

// recode contra* pregnant (. = 0)

tab cluster, gen(area)

// Create dummy crop loss
loc divide = 10000
loc strdiv "10,000"
loc cutoff = 200/`divide' // Remember to change this if we re-do units in crBase.do
gen croplostdummy = croplostamount_pc >= `cutoff' if croplostamount_pc != .
gen croplostdummy_lag  = croplostamount_pc_lag >= `cutoff' if croplostamount_pc_lag != .
gen croplostdummy_lag2 = croplostamount_pc_lag2 >= `cutoff' if croplostamount_pc_lag2 != .

// Crop loss interactions
gen croplostXassets_w1 = croplostamount_pc * assets_pc_wave1
gen croplost_lagXassets_w1 = croplostamount_pc_lag * assets_pc_wave1
gen croplostdummyXassets_w1 = croplostdummy * assets_pc_wave1
gen croplostdummy_lagXassets_w1 = croplostdummy_lag * assets_pc_wave1
tab agegroup, gen(agegp)
foreach var of varlist agegp* {
    gen croplostdummyX`var' = croplostdummy * `var'
    gen croplostdummy_lagX`var' = croplostdummy_lag * `var'
}

// Log version
gen ln_croplostamount_pc = log(croplostamount_pc+1)
gen ln_croplostamount_pc_lag = log(croplostamount_pc_lag+1)
gen ln_croplostXassets_w1 = ln_croplostamount_pc * assets_pc_wave1
gen ln_croplost_lagXassets_w1 = ln_croplostamount_pc_lag * assets_pc_wave1
gen ln_croplostXln_assets_w1 = ln_croplostamount_pc * log(assets_pc_wave1*`divide'+1)
gen ln_croplost_lagXln_assets_w1 = ln_croplostamount_pc_lag * log(assets_pc_wave1*`divide'+1)


// --------------------------------------------------------------------------
// General marital status
// Dissolution of partnership, husband in household, and shocks
// --------------------------------------------------------------------------


// Coding
// 0 is married/partnered
// > 0 is never married, divorced, widowed, etc
// Positive effects of crop loss is indicative of less likely to be married

tab marstat, m

gen dissolved = marstat == 3 | marstat == 4 if marstat != . // not married or partnered
gen married   = marstat <  3 if marstat != . // married or partnered



////////////////////////////////////////////////////
// Labels                                         //
////////////////////////////////////////////////////

loc strcut = `cutoff'*`divide'
lab var croplostdummy "Crop loss --- 1-7 months (`strcut' TZS or above)"
lab var croplostdummy_lag "Crop loss --- 7-14 months (`strcut' TZS or above)"
lab var croplostdummyXassets_w1 "Crop loss --- 1-7 months \X initial assets (`strdiv' TZS)"
lab var croplostdummy_lagXassets_w1 "Crop loss --- 7-14 months \X initial assets (`strdiv' TZS)"

// Linear version
lab var croplostamount_pc       "Crop loss --- 1-7 months (`strdiv' TZS)"
lab var croplostamount_pc_lag   "Crop loss --- 7-14 months (`strdiv' TZS)"
lab var croplostXassets_w1      "Crop loss --- 1-7 months \X initial assets (`strdiv' TZS)"
lab var croplost_lagXassets_w1  "Crop loss --- 7-14 months \X initial assets (`strdiv' TZS)"

// Log version
lab var ln_croplostamount_pc "Log crop loss --- 1-7 months"
lab var ln_croplostamount_pc_lag "Log crop loss --- 7-14 months"
lab var ln_croplostXassets_w1      "Log crop loss --- 1-7 months \X initial assets (`strdiv' TZS)"
lab var ln_croplost_lagXassets_w1  "Log crop loss --- 7-14 months \X initial assets (`strdiv' TZS)"
lab var ln_croplostXln_assets_w1      "Log crop loss --- 1-7 months \X log initial assets"
lab var ln_croplost_lagXln_assets_w1  "Log crop loss --- 7-14 months \X log initial assets"


//////////////////////////////////
// Marriage results             //
//////////////////////////////////

// general marriage status

// eststo generalMarriage: xtreg married croplostdummy pass2 pass3 pass4 , fe cluster(id_hh)
// xtreg married croplostdummy croplostdummy_lag  pass3 pass4 , fe cluster(id_hh)

// divorce and dissolution

// Drop waves with never married or reporting never married in prior waves
tempvar notmarried nevermarried 
gen `nevermarried' = .
gen `notmarried'   = marstat == 6
foreach wave of numlist 4/1 {
    by id_person (wave): replace `nevermarried' = `notmarried' == 1 | `nevermarried'[_n+1] == 1 if wave == `wave'
}
drop if `nevermarried' == 1

// conditions - married/partnered first time observed
gen marriedPeriod1 = married == 1 if passage == 1
bysort id_person (passage): egen inSample = max(marriedPeriod1)
keep if inSample

eststo divorce: xtreg dissolve croplostdummy pass3 pass4 if passage != 1 , fe cluster(id_hh)
// xtreg dissolve croplostdummy croplostdummy_lag pass3 pass4 if passage != 1 , fe cluster(id_hh)


// --------------------------------------------------------------------------
// Absence of partner/husband and crop loss shocks
// --------------------------------------------------------------------------


// Back to our regular sample
use `data'/base, clear

// data manipulation
do womenCommon 

// Impact of crop loss amount on whether the spouse is currently living in the Household
gen absent = spousehh == 2 if spousehh != .
eststo absent: xtreg absent croplostdummy pass2 pass3 pass4, fe cluster(id_hh)


// --------------------------------------------------------------------------
// BMI and illness impact from crop loss shocks
// --------------------------------------------------------------------------

eststo bmi: xtreg BMI croplostdummy pregnant pass2 pass3 pass4 , fe cluster(id_hh)
eststo ill: xtreg illdays_dummy croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)



exit


esttab absent divorce using `results'/main_marriage.tex, replace ///
    indicate(Wave dummies = pass2 pass3 pass4) ///
    drop(_cons) ///
    stats(N N_g , fmt(0) label("Observations" "Number of women")) ///
	 nogap nolines varwidth(55) label ///
	 se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) sfmt(0)

