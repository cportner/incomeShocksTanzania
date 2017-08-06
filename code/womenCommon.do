// Code common to all standard women based analyses
// womenCommon.do

////////////////////////////////////////////////////////////////////////////////////////////////
// Load data & restrict to females married/partnered & all 4 rounds below age 45 and above 18 //
////////////////////////////////////////////////////////////////////////////////////////////////

keep if female & num_waves == 4

tempvar max_marstat min_age max_age ///
    miss_birth miss_preg miss_cont miss_trad miss_mod miss_crop

by id_person: egen `max_marstat' = max(marstat)
drop if `max_marstat' >= 3

by id_person: egen `min_age' = min(ageyr)
drop if `min_age' < 18
by id_person: egen `max_age' = max(ageyr)
drop if `max_age' > 45


// missing important information
by id_person: egen `miss_birth' = count(birthtot)
by id_person: egen `miss_preg'  = count(pregnant)
by id_person: egen `miss_cont'  = count(contra_any)
by id_person: egen `miss_trad'  = count(contra_trad)
by id_person: egen `miss_mod'   = count(contra_modern)
by id_person: egen `miss_crop'  = count(crlstamt)
drop if `miss_birth' < 4 | `miss_preg' < 4 ///
    | `miss_cont' < 4 | `miss_trad' < 4 | `miss_mod' < 4 ///
    | `miss_crop' < 4
    
xtset id_person


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
