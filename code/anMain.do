// Main results
// anMain.do

vers 13.1
clear

//  short file paths - assuming work directory is "code"
loc dataDir   "../data"
loc resDir    "../tables"

////////////////////////////////////////////////////////////////////////////////////////////////
// Load data & restrict to females married/partnered & all 4 rounds below age 45 and above 18 //
////////////////////////////////////////////////////////////////////////////////////////////////

use `dataDir'/base

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
lab var croplostdummy "Crop loss - 1-7 months (`strcut' TZS or above)"
lab var croplostdummy_lag "Crop loss - 7-14 months (`strcut' TZS or above)"
lab var croplostdummyXassets_w1 "Crop loss - 1-7 months \X initial assets (`strdiv' TZS)"
lab var croplostdummy_lagXassets_w1 "Crop loss - 7-14 months \X initial assets (`strdiv' TZS)"

// Linear version
lab var croplostamount_pc       "Crop loss - 1-7 months (`strdiv' TZS)"
lab var croplostamount_pc_lag   "Crop loss - 7-14 months (`strdiv' TZS)"
lab var croplostXassets_w1      "Crop loss - 1-7 months \X initial assets (`strdiv' TZS)"
lab var croplost_lagXassets_w1  "Crop loss - 7-14 months \X initial assets (`strdiv' TZS)"

// Log version
lab var ln_croplostamount_pc "Log crop loss - 1-7 months"
lab var ln_croplostamount_pc_lag "Log crop loss - 7-14 months"
lab var ln_croplostXassets_w1      "Log crop loss - 1-7 months \X initial assets (`strdiv' TZS)"
lab var ln_croplost_lagXassets_w1  "Log crop loss - 7-14 months \X initial assets (`strdiv' TZS)"
lab var ln_croplostXln_assets_w1      "Log crop loss - 1-7 months \X log initial assets"
lab var ln_croplost_lagXln_assets_w1  "Log crop loss - 7-14 months \X log initial assets"

//////////////////////////////
// Results for Main results //
//////////////////////////////

// OLS - base specification without wave 1 asset interaction
loc xvar = " assets_pc_wave1 i.educ017 i.agegroup "
eststo lpm_ca_0: reg contra_any croplostdummy  pass2 pass3 pass4 `xvar', cluster(id_hh)
estadd local fixed "No" , replace
eststo lpm_ct_0: reg contra_trad croplostdummy  pass2 pass3 pass4 `xvar', cluster(id_hh)
estadd local fixed "No" , replace
eststo lpm_cm_0: reg contra_mode croplostdummy  pass2 pass3 pass4 `xvar', cluster(id_hh)
estadd local fixed "No" , replace
eststo lpm_pr_0: reg pregnant croplostdummy  pass2 pass3 pass4 `xvar', cluster(id_hh)
estadd local fixed "No" , replace
eststo lpm_br_0: reg birth croplostdummy_lag  pass3 pass4 `xvar', cluster(id_hh)
estadd local fixed "No" , replace

// Community fixed effects - base specification without wave 1 asset interaction
loc xvar = " assets_pc_wave1 i.educ017 i.agegroup i.cluster"
eststo lpm_ca_1: reg contra_any croplostdummy  pass2 pass3 pass4 `xvar', cluster(id_hh)
estadd local fixed "No" , replace
eststo lpm_ct_1: reg contra_trad croplostdummy  pass2 pass3 pass4 `xvar', cluster(id_hh)
estadd local fixed "No" , replace
eststo lpm_cm_1: reg contra_mode croplostdummy  pass2 pass3 pass4 `xvar', cluster(id_hh)
estadd local fixed "No" , replace
eststo lpm_pr_1: reg pregnant croplostdummy  pass2 pass3 pass4 `xvar', cluster(id_hh)
estadd local fixed "No" , replace
eststo lpm_br_1: reg birth croplostdummy_lag  pass3 pass4 `xvar', cluster(id_hh)
estadd local fixed "No" , replace

// Woman fixed effects base specification without wave 1 asset interaction
eststo d_ca_1: xtreg contra_any croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
eststo d_ct_1: xtreg contra_trad croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
eststo d_cm_1: xtreg contra_mode croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
eststo d_pr_1: xtreg pregnant croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
eststo d_br_1: xtreg birth croplostdummy_lag  pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace



/////////////////////////////////////////////////
// Tables                                      //
/////////////////////////////////////////////////

// In main text tables

// Pregnancy and birth table
esttab  lpm_pr_0 lpm_pr_1 d_pr_1  lpm_br_0 lpm_br_1  d_br_1  using `resDir'/main_w1_pregnant_birth.tex, replace ///
    indicate("Wave dummies = pass2 pass3 pass4" "Community dummies = *cluster*") ///
    s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
	nogap nolines varwidth(55) label ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) sfmt(0) ///
    drop(_cons assets_pc_wave1 *educ017* *agegroup*)	

// Contraceptive use table
esttab lpm_ca_0 lpm_ca_1 d_ca_1  using `resDir'/main_w1_contraceptives.tex, replace ///
    indicate("Wave dummies = pass2 pass3 pass4" "Community dummies = *cluster*") ///
    s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
	nogap nolines varwidth(55) label ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop(_cons assets_pc_wave1 *educ017* *agegroup*)

esttab lpm_ct_0 lpm_ct_1  d_ct_1 using `resDir'/main_w1_contraceptives.tex, append ///
    indicate("Wave dummies = pass2 pass3 pass4" "Community dummies = *cluster*") ///
    s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
	nogap nolines varwidth(55) label ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop(_cons assets_pc_wave1 *educ017* *agegroup*)

esttab lpm_cm_0 lpm_cm_1  d_cm_1 using `resDir'/main_w1_contraceptives.tex, append ///
    indicate("Wave dummies = pass2 pass3 pass4" "Community dummies = *cluster*") ///
    s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
	nogap nolines varwidth(55) label ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop(_cons assets_pc_wave1 *educ017* *agegroup*)	



// Full OLS tables 

esttab lpm_pr_0 lpm_pr_1 lpm_br_0 lpm_br_1  using `resDir'/ols_full_fertility_w1.tex, replace ///
    indicate("Wave dummies = pass2 pass3 pass4" "Community dummies = *cluster*") ///
    s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
	nogap nolines varwidth(55) label ///
	nobaselevels ///
    varlabels( ///
        _Ieduc017==1  "1 - 6 years of education" ///
        _Ieduc017_7  "7 plus years of education" ///
        _Iagegroup_16 "Age 18-22" ///
        _Iagegroup_23 "Age 23-27" ///
        _Iagegroup_28 "Age 28-32" ///
        _Iagegroup_33 "Age 33-37" ///
        _Iagegroup_38 "Age 38-45" ///
        _cons         "Constant"  ///
    ) ///  
    order(croplostdummy croplostdummy_lag) ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) 

esttab lpm_ca_0 lpm_ca_1 lpm_ct_0 lpm_ct_1 lpm_cm_0 lpm_cm_1 using `resDir'/ols_full_contraceptives_w1.tex, replace ///
    indicate("Wave dummies = pass2 pass3 pass4" "Community dummies = *cluster*") ///
    s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
	nogap nolines varwidth(55) label ///
	nobaselevels ///
    varlabels( ///
        _Ieduc017==1  "1 - 6 years of education" ///
        _Ieduc017_7  "7 plus years of education" ///
        _Iagegroup_16 "Age 18-22" ///
        _Iagegroup_23 "Age 23-27" ///
        _Iagegroup_28 "Age 28-32" ///
        _Iagegroup_33 "Age 33-37" ///
        _Iagegroup_38 "Age 38-45" ///
        _cons         "Constant"  ///
    ) ///  
    order(croplostdummy croplostdummy_lag) ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) 




eststo clear

// Descriptive statistics

xi , noomit: estpost  sum assets_pc_wave1 i.educ017 i.agegroup if wave == 1 

esttab using `resDir'/desstat1.tex , ///
    cells("mean(fmt(2)) sd(fmt(2)) ") ///
    varlabels( ///
        _Ieduc017_0  "No education" ///
        _Ieduc017_1  "1 - 6 years of education" ///
        _Ieduc017_7  "7 plus years of education" ///
        _Iagegroup_16 "Age 18-22" ///
        _Iagegroup_23 "Age 23-27" ///
        _Iagegroup_28 "Age 28-32" ///
        _Iagegroup_33 "Age 33-37" ///
        _Iagegroup_38 "Age 38-45" ///
    ) ///  
    stats(N , fmt(0) label("Number of women")) ///
    nogap nolines varwidth(55) label ///
    nomtitle nonumber replace

sum assets_pc_wave1 if wave == 1, detail

eststo clear

estpost tabstat croplostdummy contra_any contra_trad contra_modern pregnant birth , ///
    by(wave) statistics(mean sd) columns(statistics) listwise


esttab using `resDir'/desstat2.tex , ///
    main(mean 2) aux(sd 2) nostar unstack ///
    varlabels( ///
        pregnant "Currently pregnant" ///
    ) ///
    nogap nolines varwidth(55) label ///
    noobs nonote nomtitle nonumber replace

    