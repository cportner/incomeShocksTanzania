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


// Household fixed effects base specification without wave 1 asset interaction
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



exit


//////////////////////////////////////////////////////////////
// OLS LPM Regressions with continuous crop loss   //
//////////////////////////////////////////////////////////////

// base specification without wave 1 asset interaction
reg contra_any croplostamount_pc  pass2 pass3 pass4 ,  cluster(id_hh)
reg contra_trad croplostamount_pc  pass2 pass3 pass4 ,  cluster(id_hh)
reg contra_mode croplostamount_pc  pass2 pass3 pass4 ,  cluster(id_hh)
reg pregnant croplostamount_pc  pass2 pass3 pass4 ,  cluster(id_hh)
reg pregnant croplostamount_pc_lag   pass3 pass4 ,  cluster(id_hh)
reg pregnant croplostamount_pc ///
	croplostamount_pc_lag  pass3 pass4 ,  cluster(id_hh)
reg birth croplostamount_pc_lag  pass3 pass4 ,  cluster(id_hh)

// base specification with interaction with wave 1 assets
reg contra_any croplostamount_pc croplostXassets_w1 pass2 pass3 pass4 ,  cluster(id_hh)
reg contra_trad croplostamount_pc croplostXassets_w1 pass2 pass3 pass4 ,  cluster(id_hh)
reg contra_mode croplostamount_pc croplostXassets_w1 pass2 pass3 pass4 ,  cluster(id_hh)
reg pregnant croplostamount_pc croplostXassets_w1 pass2 pass3 pass4 ,  cluster(id_hh)
reg pregnant croplostamount_pc_lag croplost_lagXassets_w1  pass3 pass4 ,  cluster(id_hh)
reg pregnant croplostamount_pc croplostXassets_w1 ///
	croplostamount_pc_lag croplost_lagXassets_w1 pass3 pass4 ,  cluster(id_hh)
reg birth croplostamount_pc_lag croplost_lagXassets_w1  pass3 pass4 ,  cluster(id_hh)

// Age interaction
reg contra_any c.croplostamount_pc#agegroup c.croplostXassets_w1#agegroup pass2 pass3 pass4 ,  cluster(id_hh)
reg contra_trad c.croplostamount_pc#agegroup c.croplostXassets_w1#agegroup pass2 pass3 pass4 ,  cluster(id_hh)
reg contra_mode c.croplostamount_pc#agegroup c.croplostXassets_w1#agegroup pass2 pass3 pass4 ,  cluster(id_hh)
reg pregnant c.croplostamount_pc#agegroup c.croplostXassets_w1#agegroup pass2 pass3 pass4 ,  cluster(id_hh)
reg pregnant c.croplostamount_pc_lag#agegroup c.croplost_lagXassets_w1#agegroup  pass3 pass4 ,  cluster(id_hh)
reg pregnant c.croplostamount_pc#agegroup c.croplostXassets_w1#agegroup ///
	c.croplostamount_pc_lag#agegroup c.croplost_lagXassets_w1#agegroup pass3 pass4 ,  cluster(id_hh)
reg birth c.croplostamount_pc_lag#agegroup c.croplost_lagXassets_w1#agegroup pass3 pass4 ,  cluster(id_hh)



//////////////////////////////////////////////////////////////
// Fixed effect LPM Regressions with continuous crop loss   //
//////////////////////////////////////////////////////////////

eststo clear

// base specification without wave 1 asset interaction
eststo cfe_c_a:  xtreg contra_any croplostamount_pc  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
eststo cfe_c_tr: xtreg contra_trad croplostamount_pc  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
eststo cfe_c_mo: xtreg contra_mode croplostamount_pc  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
eststo cfe_pr:   xtreg pregnant croplostamount_pc  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
xtreg pregnant croplostamount_pc_lag   pass3 pass4 , fe cluster(id_hh)
xtreg pregnant croplostamount_pc ///
	croplostamount_pc_lag  pass3 pass4 , fe cluster(id_hh)
eststo cfe_br:   xtreg birth croplostamount_pc_lag  pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace

// base specification with interaction with wave 1 assets
eststo cfe_int_c_a:  xtreg contra_any croplostamount_pc croplostXassets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
eststo cfe_int_c_tr: xtreg contra_trad croplostamount_pc croplostXassets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
eststo cfe_int_c_mo: xtreg contra_mode croplostamount_pc croplostXassets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
eststo cfe_int_pr:   xtreg pregnant croplostamount_pc croplostXassets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
xtreg pregnant croplostamount_pc_lag croplost_lagXassets_w1  pass3 pass4 , fe cluster(id_hh)
xtreg pregnant croplostamount_pc croplostXassets_w1 ///
	croplostamount_pc_lag croplost_lagXassets_w1 pass3 pass4 , fe cluster(id_hh)
eststo cfe_int_br:   xtreg birth croplostamount_pc_lag croplost_lagXassets_w1  pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace

// // Age interaction
// xtreg contra_any c.croplostamount_pc#agegroup c.croplostXassets_w1#agegroup pass2 pass3 pass4 , fe cluster(id_hh)
// xtreg contra_trad c.croplostamount_pc#agegroup c.croplostXassets_w1#agegroup pass2 pass3 pass4 , fe cluster(id_hh)
// xtreg contra_mode c.croplostamount_pc#agegroup c.croplostXassets_w1#agegroup pass2 pass3 pass4 , fe cluster(id_hh)
// xtreg pregnant c.croplostamount_pc#agegroup c.croplostXassets_w1#agegroup pass2 pass3 pass4 , fe cluster(id_hh)
// xtreg pregnant c.croplostamount_pc_lag#agegroup c.croplost_lagXassets_w1#agegroup  pass3 pass4 , fe cluster(id_hh)
// xtreg pregnant c.croplostamount_pc#agegroup c.croplostXassets_w1#agegroup ///
// 	c.croplostamount_pc_lag#agegroup c.croplost_lagXassets_w1#agegroup pass3 pass4 , fe cluster(id_hh)
// xtreg birth c.croplostamount_pc_lag#agegroup c.croplost_lagXassets_w1#agegroup pass3 pass4 , fe cluster(id_hh)

// esttab cfe_c_* cfe_int_c* using `results'/continuous_w1_contraceptive.tex, replace ///
//     indicate(Wave dummies = pass2 pass3 pass4) ///
//     drop(_cons) ///
//     s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
// 	 nogap nolines varwidth(55) label ///
// 	 se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) sfmt(0)
// 
// esttab cfe_pr cfe_int_pr cfe_br cfe_int_br using `results'/continuous_w1_pregnant_birth.tex, replace ///
//     indicate(Wave dummies = pass2 pass3 pass4) ///
//     drop(_cons) ///
//     s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
// 	nogap nolines varwidth(55) label ///
// 	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) sfmt(0)


esttab cfe_pr cfe_br cfe_c_*  using `results'/continuous_w1.tex, replace ///
    indicate(Wave dummies = pass2 pass3 pass4) ///
    drop(_cons) ///
    s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
	 nogap nolines varwidth(55) label ///
	 se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) sfmt(0)

esttab cfe_int_pr cfe_int_br cfe_int_c_* using `results'/continuous_w1.tex, append ///
    indicate(Wave dummies = pass2 pass3 pass4) ///
    drop(_cons) ///
    s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
	nogap nolines varwidth(55) label ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) sfmt(0)


//////////////////////////////////////////////////////////////////
// Fixed effect LPM Regressions with log continuous crop loss   //
//////////////////////////////////////////////////////////////////

eststo clear


// base specification without wave 1 asset interaction
eststo lnfe_c_a:  xtreg contra_any ln_croplostamount_pc  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
eststo lnfe_c_tr: xtreg contra_trad ln_croplostamount_pc  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
eststo lnfe_c_mo: xtreg contra_mode ln_croplostamount_pc  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
eststo lnfe_pr:   xtreg pregnant ln_croplostamount_pc  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
xtreg pregnant ln_croplostamount_pc_lag   pass3 pass4 , fe cluster(id_hh)
xtreg pregnant ln_croplostamount_pc ///
	ln_croplostamount_pc_lag  pass3 pass4 , fe cluster(id_hh)
eststo lnfe_br:   xtreg birth ln_croplostamount_pc_lag  pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace

// base specification with interaction with wave 1 assets
eststo lnfe_int_c_a:  xtreg contra_any ln_croplostamount_pc ln_croplostXassets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
eststo lnfe_int_c_tr: xtreg contra_trad ln_croplostamount_pc ln_croplostXassets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
eststo lnfe_int_c_mo: xtreg contra_mode ln_croplostamount_pc ln_croplostXassets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
eststo lnfe_int_pr:   xtreg pregnant ln_croplostamount_pc ln_croplostXassets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
xtreg pregnant ln_croplostamount_pc_lag ln_croplost_lagXassets_w1  pass3 pass4 , fe cluster(id_hh)
xtreg pregnant ln_croplostamount_pc ln_croplostXassets_w1 ///
	croplostamount_pc_lag ln_croplost_lagXassets_w1 pass3 pass4 , fe cluster(id_hh)
eststo lnfe_int_br:   xtreg birth ln_croplostamount_pc_lag ln_croplost_lagXassets_w1  pass3 pass4 , fe cluster(id_hh)

// base specification with interaction with log of wave 1 assets
eststo lnlnfe_int_c_a:  xtreg contra_any ln_croplostamount_pc ln_croplostXln_assets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
eststo lnlnfe_int_c_tr: xtreg contra_trad ln_croplostamount_pc ln_croplostXln_assets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
eststo lnlnfe_int_c_mo: xtreg contra_mode ln_croplostamount_pc ln_croplostXln_assets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
eststo lnlnfe_int_pr:   xtreg pregnant ln_croplostamount_pc ln_croplostXln_assets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
xtreg pregnant ln_croplostamount_pc_lag ln_croplost_lagXln_assets_w1  pass3 pass4 , fe cluster(id_hh)
xtreg pregnant ln_croplostamount_pc ln_croplostXln_assets_w1 ///
	croplostamount_pc_lag ln_croplost_lagXln_assets_w1 pass3 pass4 , fe cluster(id_hh)
eststo lnlnfe_int_br:   xtreg birth ln_croplostamount_pc_lag ln_croplost_lagXln_assets_w1  pass3 pass4 , fe cluster(id_hh)


// // Age interaction
// xtreg contra_any c.croplostamount_pc#agegroup c.croplostXassets_w1#agegroup pass2 pass3 pass4 , fe cluster(id_hh)
// xtreg contra_trad c.croplostamount_pc#agegroup c.croplostXassets_w1#agegroup pass2 pass3 pass4 , fe cluster(id_hh)
// xtreg contra_mode c.croplostamount_pc#agegroup c.croplostXassets_w1#agegroup pass2 pass3 pass4 , fe cluster(id_hh)
// xtreg pregnant c.croplostamount_pc#agegroup c.croplostXassets_w1#agegroup pass2 pass3 pass4 , fe cluster(id_hh)
// xtreg pregnant c.croplostamount_pc_lag#agegroup c.croplost_lagXassets_w1#agegroup  pass3 pass4 , fe cluster(id_hh)
// xtreg pregnant c.croplostamount_pc#agegroup c.croplostXassets_w1#agegroup ///
// 	c.croplostamount_pc_lag#agegroup c.croplost_lagXassets_w1#agegroup pass3 pass4 , fe cluster(id_hh)
// xtreg birth c.croplostamount_pc_lag#agegroup c.croplost_lagXassets_w1#agegroup pass3 pass4 , fe cluster(id_hh)

// esttab lnfe_c_* using `results'/appendix_w1_contraceptive.tex, replace ///
//     indicate(Wave dummies = pass2 pass3 pass4) ///
//     drop(_cons) ///
//     s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
// 	nogap nolines varwidth(55) label ///
// 	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) sfmt(0)
// 
// esttab lnfe_pr  lnfe_br  using `results'/appendix_w1_pregnant_birth.tex, replace ///
//     indicate(Wave dummies = pass2 pass3 pass4) ///
//     drop(_cons) ///
//     s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
// 	nogap nolines varwidth(55) label ///
// 	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) sfmt(0)


esttab lnfe_pr lnfe_br lnfe_c_*  using `results'/log_w1.tex, replace ///
    indicate(Wave dummies = pass2 pass3 pass4) ///
    drop(_cons) ///
    s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
	 nogap nolines varwidth(55) label ///
	 se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) sfmt(0)

esttab lnfe_int_pr lnfe_int_br lnfe_int_c_* using `results'/log_w1.tex, append ///
    indicate(Wave dummies = pass2 pass3 pass4) ///
    drop(_cons) ///
    s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
	nogap nolines varwidth(55) label ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) sfmt(0)

esttab lnlnfe_int_pr lnlnfe_int_br lnlnfe_int_c_* using `results'/log_w1.tex, append ///
    indicate(Wave dummies = pass2 pass3 pass4) ///
    drop(_cons) ///
    s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
	nogap nolines varwidth(55) label ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) sfmt(0)


////////////////////////////////////////////////////
// OLS LPM with dummy crop loss		              //
////////////////////////////////////////////////////

eststo clear

tab cluster, gen(area)

// True OLS 

loc xvar = " assets_pc_wave1 i.educ017 i.agegroup "

// base specification without wave 1 asset interaction
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

// base specification without wave 1 asset interaction - clustering at cluster level
eststo clust_lpm_ca_0: reg contra_any croplostdummy  pass2 pass3 pass4 `xvar', cluster(cluster)
estadd local fixed "No" , replace
eststo clust_lpm_ct_0: reg contra_trad croplostdummy  pass2 pass3 pass4 `xvar', cluster(cluster)
estadd local fixed "No" , replace
eststo clust_lpm_cm_0: reg contra_mode croplostdummy  pass2 pass3 pass4 `xvar', cluster(cluster)
estadd local fixed "No" , replace
eststo clust_lpm_pr_0: reg pregnant croplostdummy  pass2 pass3 pass4 `xvar', cluster(cluster)
estadd local fixed "No" , replace
eststo clust_lpm_br_0: reg birth croplostdummy_lag  pass3 pass4 `xvar', cluster(cluster)
estadd local fixed "No" , replace

// Testing for coefficient across OLS estimates
reg contra_any croplostdummy  pass2 pass3 pass4 `xvar', 
est store contra
reg pregnant croplostdummy  pass2 pass3 pass4 `xvar', 
est store pregnant
reg birth croplostdummy_lag  pass3 pass4 `xvar', 
est store birth

suest birth pregnant contra, cluster(id_hh)

test [birth_mean]croplostdummy_lag = [pregnant_mean]croplostdummy
test [birth_mean]croplostdummy_lag = -[contra_mean]croplostdummy
test [contra_mean]croplostdummy = -[pregnant_mean]croplostdummy

exit


loc xvar = " assets_pc_wave1 i.educ017 i.agegroup i.cluster"

// xtset cluster
// // base specification without wave 1 asset interaction
// eststo lpm_ca_1: xtreg contra_any croplostdummy  pass2 pass3 pass4 `xvar', fe 
// estadd local fixed "No" , replace
// eststo lpm_ct_1: xtreg contra_trad croplostdummy  pass2 pass3 pass4 `xvar', fe 
// estadd local fixed "No" , replace
// eststo lpm_cm_1: xtreg contra_mode croplostdummy  pass2 pass3 pass4 `xvar', fe 
// estadd local fixed "No" , replace
// eststo lpm_pr_1: xtreg pregnant croplostdummy  pass2 pass3 pass4 `xvar', fe 
// estadd local fixed "No" , replace
// eststo lpm_br_1: xtreg birth croplostdummy_lag  pass3 pass4 `xvar', fe 
// estadd local fixed "No" , replace
// xtset id_woman

// base specification without wave 1 asset interaction
eststo lpm_ca_1: reg contra_any croplostdummy  pass2 pass3 pass4 `xvar', cluster(id_hh)
estadd local fixed "No" , replace
eststo lpm_ct_1: reg contra_trad croplostdummy  pass2 pass3 pass4 `xvar', cluster(id_hh)
estadd local fixed "No" , replace
eststo lpm_cm_1: reg contra_mode croplostdummy  pass2 pass3 pass4 `xvar', cluster(id_hh)
estadd local fixed "No" , replace
eststo lpm_pr_1: reg pregnant croplostdummy  pass2 pass3 pass4 `xvar', cluster(id_hh)
estadd local fixed "No" , replace
reg pregnant croplostdummy_lag   pass3 pass4 `xvar', cluster(id_hh)
reg pregnant croplostdummy ///
	croplostdummy_lag  pass3 pass4 `xvar', cluster(id_hh)
eststo lpm_br_1: reg birth croplostdummy_lag  pass3 pass4 `xvar', cluster(id_hh)
estadd local fixed "No" , replace
reg birth croplostdummy_lag croplostdummy_lag2  pass4 `xvar', cluster(id_hh)

// base specification without wave 1 asset interaction - clustering at cluster level
eststo clust_lpm_ca_1: reg contra_any croplostdummy  pass2 pass3 pass4 `xvar', cluster(cluster)
estadd local fixed "No" , replace
eststo clust_lpm_ct_1: reg contra_trad croplostdummy  pass2 pass3 pass4 `xvar', cluster(cluster)
estadd local fixed "No" , replace
eststo clust_lpm_cm_1: reg contra_mode croplostdummy  pass2 pass3 pass4 `xvar', cluster(cluster)
estadd local fixed "No" , replace
eststo clust_lpm_pr_1: reg pregnant croplostdummy  pass2 pass3 pass4 `xvar', cluster(cluster)
estadd local fixed "No" , replace
reg pregnant croplostdummy_lag   pass3 pass4 `xvar', cluster(cluster)
reg pregnant croplostdummy ///
	croplostdummy_lag  pass3 pass4 `xvar', cluster(cluster)
eststo clust_lpm_br_1: reg birth croplostdummy_lag  pass3 pass4 `xvar', cluster(cluster)
estadd local fixed "No" , replace
reg birth croplostdummy_lag croplostdummy_lag2  pass4 `xvar', cluster(cluster)


// base specification with interaction with wave 1 assets
eststo lpm_int_ca: reg contra_any croplostdummy croplostdummyXassets_w1 pass2 pass3 pass4 , cluster(id_hh)
eststo lpm_int_ct: reg contra_trad croplostdummy croplostdummyXassets_w1 pass2 pass3 pass4 , cluster(id_hh)
eststo lpm_int_cm: reg contra_mode croplostdummy croplostdummyXassets_w1 pass2 pass3 pass4 , cluster(id_hh)
eststo lpm_int_pr: reg pregnant croplostdummy croplostdummyXassets_w1 pass2 pass3 pass4 , cluster(id_hh)
reg pregnant croplostdummy_lag croplostdummy_lagXassets_w1  pass3 pass4 , cluster(id_hh)
reg pregnant croplostdummy croplostdummyXassets_w1 ///
	croplostdummy_lag croplostdummy_lagXassets_w1 pass3 pass4 , cluster(id_hh)
eststo lpm_int_br: reg birth croplostdummy_lag croplostdummy_lagXassets_w1  pass3 pass4 , cluster(id_hh)

// Age interaction
eststo lpm_age_ca: reg contra_any i1.croplostdummy#agegroup c.croplostdummyXassets_w1#agegroup pass2 pass3 pass4 , cluster(id_hh)
eststo lpm_age_ct: reg contra_trad i1.croplostdummy#agegroup c.croplostdummyXassets_w1#agegroup pass2 pass3 pass4 , cluster(id_hh)
// eststo lpm_age_cm: reg contra_mode i1.croplostdummy#agegroup c.croplostdummyXassets_w1#agegroup pass2 pass3 pass4 , cluster(id_hh)
eststo lpm_age_pr: reg pregnant i1.croplostdummy#agegroup c.croplostdummyXassets_w1#agegroup pass2 pass3 pass4 , cluster(id_hh)
reg pregnant i1.croplostdummy_lag#agegroup c.croplostdummy_lagXassets_w1#agegroup  pass3 pass4 , cluster(id_hh)
reg pregnant i1.croplostdummy#agegroup c.croplostdummyXassets_w1#agegroup ///
	i1.croplostdummy_lag#agegroup c.croplostdummy_lagXassets_w1#agegroup pass3 pass4 , cluster(id_hh)
eststo lpm_age_br: reg birth i1.croplostdummy_lag#agegroup c.croplostdummy_lagXassets_w1#agegroup pass3 pass4 , cluster(id_hh)

////////////////////////////////////////////////////
// Fixed effect LPM with dummy crop loss		  //
////////////////////////////////////////////////////

// base specification without wave 1 asset interaction
eststo d_ca_1: xtreg contra_any croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
eststo d_ct_1: xtreg contra_trad croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
eststo d_cm_1: xtreg contra_mode croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
eststo d_pr_1: xtreg pregnant croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
xtreg pregnant croplostdummy_lag   pass3 pass4 , fe cluster(id_hh)
xtreg pregnant croplostdummy ///
	croplostdummy_lag  pass3 pass4 , fe cluster(id_hh)
eststo d_br_1: xtreg birth croplostdummy_lag  pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
xtreg birth croplostdummy_lag croplostdummy_lag2  pass4 , fe cluster(id_hh)

// Testing coefficients across models - need to use OLS for this and then suest
// see http://www.stata.com/statalist/archive/2011-01/msg00507.html
// and http://www.stata.com/statalist/archive/2006-06/msg00837.html
// dof correction has no impact, probably because suest takes account of the clustering
xtreg birth croplostdummy_lag  pass3 pass4 , fe cluster(id_hh)
// xtreg birth croplostdummy_lag  pass3 pass4 , fe
// loc dof = `e(df_r)'
by id_woman: center birth croplostdummy_lag  pass3 pass4 if e(sample)
// reg c_birth c_croplostdummy_lag  c_pass3 c_pass4, dof(`dof')  nocons 
reg c_birth c_croplostdummy_lag  c_pass3 c_pass4,   nocons 
est store fe_birth

xtreg pregnant croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
// xtreg pregnant croplostdummy  pass2 pass3 pass4 , fe 
// loc dof = `e(df_r)'
by id_woman: center pregnant croplostdummy  pass2 pass3 pass4 if e(sample) , prefix(d_)
// reg d_pregnant d_croplostdummy  d_pass2 d_pass3 d_pass4, dof(`dof') nocons 
reg d_pregnant d_croplostdummy  d_pass2 d_pass3 d_pass4,  nocons 
est store fe_pregnant

xtreg contra_any croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
// xtreg contra_any croplostdummy  pass2 pass3 pass4 , fe 
// loc dof = `e(df_r)'
by id_woman: center contra_any croplostdummy  pass2 pass3 pass4 if e(sample) , prefix(e_)
// reg e_contra_any e_croplostdummy  e_pass2 e_pass3 e_pass4 , dof(`dof')  nocons 
reg e_contra_any e_croplostdummy  e_pass2 e_pass3 e_pass4 ,  nocons 
est store fe_contra

suest fe_birth fe_pregnant fe_contra , cluster(id_hh)

test [fe_birth_mean]c_croplostdummy_lag = [fe_pregnant_mean]d_croplostdummy
test [fe_birth_mean]c_croplostdummy_lag = -[fe_contra_mean]e_croplostdummy
test [fe_contra_mean]e_croplostdummy = -[fe_pregnant_mean]d_croplostdummy



// base specification without wave 1 asset interaction - clustering at community level
eststo clust_d_ca_1: xtreg contra_any croplostdummy  pass2 pass3 pass4 , fe cluster(cluster)
estadd local fixed "Yes" , replace
eststo clust_d_ct_1: xtreg contra_trad croplostdummy  pass2 pass3 pass4 , fe cluster(cluster)
estadd local fixed "Yes" , replace
eststo clust_d_cm_1: xtreg contra_mode croplostdummy  pass2 pass3 pass4 , fe cluster(cluster)
estadd local fixed "Yes" , replace
eststo clust_d_pr_1: xtreg pregnant croplostdummy  pass2 pass3 pass4 , fe cluster(cluster)
estadd local fixed "Yes" , replace
xtreg pregnant croplostdummy_lag   pass3 pass4 , fe cluster(cluster)
xtreg pregnant croplostdummy ///
	croplostdummy_lag  pass3 pass4 , fe cluster(cluster)
eststo clust_d_br_1: xtreg birth croplostdummy_lag  pass3 pass4 , fe cluster(cluster)
estadd local fixed "Yes" , replace
xtreg birth croplostdummy_lag croplostdummy_lag2  pass4 , fe cluster(cluster)

// base specification with interaction with wave 1 assets
eststo d_int_ca: xtreg contra_any croplostdummy croplostdummyXassets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
eststo d_int_ct: xtreg contra_trad croplostdummy croplostdummyXassets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
eststo d_int_cm: xtreg contra_mode croplostdummy croplostdummyXassets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
eststo d_int_pr: xtreg pregnant croplostdummy croplostdummyXassets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
xtreg pregnant croplostdummy_lag croplostdummy_lagXassets_w1  pass3 pass4 , fe cluster(id_hh)
xtreg pregnant croplostdummy croplostdummyXassets_w1 ///
	croplostdummy_lag croplostdummy_lagXassets_w1 pass3 pass4 , fe cluster(id_hh)
eststo d_int_br: xtreg birth croplostdummy_lag croplostdummy_lagXassets_w1  pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace

// Age interaction
eststo d_age_ca: xtreg contra_any i1.croplostdummy#agegroup  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
eststo d_age_ct: xtreg contra_trad i1.croplostdummy#agegroup  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
eststo d_age_cm: xtreg contra_mode i1.croplostdummy#agegroup  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
eststo d_age_pr: xtreg pregnant i1.croplostdummy#agegroup  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
eststo d_age_br: xtreg birth i1.croplostdummy_lag#agegroup  pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace


////////////////////////////////////////////////////
// Fixed effect Logit with dummy crop loss		  //
////////////////////////////////////////////////////

// base specification without wave 1 asset interaction
eststo logit_ca_1: xtlogit contra_any croplostdummy  pass2 pass3 pass4 , fe 
estadd local fixed "Yes" , replace
eststo logit_ct_1: xtlogit contra_trad croplostdummy  pass2 pass3 pass4 , fe 
estadd local fixed "Yes" , replace
eststo logit_cm_1: xtlogit contra_mode croplostdummy  pass2 pass3 pass4 , fe 
estadd local fixed "Yes" , replace
eststo logit_pr_1: xtlogit pregnant croplostdummy  pass2 pass3 pass4 , fe 
estadd local fixed "Yes" , replace
xtlogit pregnant croplostdummy_lag   pass3 pass4 , fe 
xtlogit pregnant croplostdummy ///
	croplostdummy_lag  pass3 pass4 , fe 
eststo logit_br_1: xtlogit birth croplostdummy_lag  pass3 pass4 , fe 
estadd local fixed "Yes" , replace
xtlogit birth croplostdummy_lag croplostdummy_lag2  pass4 , fe 

// base specification with interaction with wave 1 assets
eststo logit_int_ca: xtlogit contra_any croplostdummy croplostdummyXassets_w1 pass2 pass3 pass4 , fe 
eststo logit_int_ct: xtlogit contra_trad croplostdummy croplostdummyXassets_w1 pass2 pass3 pass4 , fe 
eststo logit_int_cm: xtlogit contra_mode croplostdummy croplostdummyXassets_w1 pass2 pass3 pass4 , fe 
eststo logit_int_pr: xtlogit pregnant croplostdummy croplostdummyXassets_w1 pass2 pass3 pass4 , fe 
xtlogit pregnant croplostdummy_lag croplostdummy_lagXassets_w1  pass3 pass4 , fe 
xtlogit pregnant croplostdummy croplostdummyXassets_w1 ///
	croplostdummy_lag croplostdummy_lagXassets_w1 pass3 pass4 , fe 
eststo logit_int_br: xtlogit birth croplostdummy_lag croplostdummy_lagXassets_w1  pass3 pass4 , fe 

// Age interaction
eststo logit_age_ca: xtlogit contra_any i1.croplostdummy#agegroup  pass2 pass3 pass4 , fe 
eststo logit_age_ct: xtlogit contra_trad i1.croplostdummy#agegroup  pass2 pass3 pass4 , fe 
eststo logit_age_cm: xtlogit contra_mode i1.croplostdummy#agegroup  pass2 pass3 pass4 , fe 
eststo logit_age_pr: xtlogit pregnant i1.croplostdummy#agegroup  pass2 pass3 pass4 , fe 
eststo logit_age_br: xtlogit birth i1.croplostdummy_lag#agegroup  pass3 pass4 , fe 

/////////////////////////////////////////////////
// Tables                                      //
/////////////////////////////////////////////////

// In main text tables

// Pregnancy and birth table
esttab  lpm_pr_0 lpm_pr_1 d_pr_1  lpm_br_0 lpm_br_1  d_br_1  using `results'/main_w1_pregnant_birth.tex, replace ///
    indicate("Wave dummies = pass2 pass3 pass4" "Community dummies = *cluster*") ///
    s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
	nogap nolines varwidth(55) label ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) sfmt(0) ///
    drop(_cons assets_pc_wave1 *educ017* *agegroup*)	

// Contraceptive use table
esttab lpm_ca_0 lpm_ca_1 d_ca_1  using `results'/main_w1_contraceptives.tex, replace ///
    indicate("Wave dummies = pass2 pass3 pass4" "Community dummies = *cluster*") ///
    s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
	nogap nolines varwidth(55) label ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop(_cons assets_pc_wave1 *educ017* *agegroup*)

esttab lpm_ct_0 lpm_ct_1  d_ct_1 using `results'/main_w1_contraceptives.tex, append ///
    indicate("Wave dummies = pass2 pass3 pass4" "Community dummies = *cluster*") ///
    s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
	nogap nolines varwidth(55) label ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop(_cons assets_pc_wave1 *educ017* *agegroup*)

esttab lpm_cm_0 lpm_cm_1  d_cm_1 using `results'/main_w1_contraceptives.tex, append ///
    indicate("Wave dummies = pass2 pass3 pass4" "Community dummies = *cluster*") ///
    s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
	nogap nolines varwidth(55) label ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop(_cons assets_pc_wave1 *educ017* *agegroup*)	


// Appendix - clustering at cluster level

// Pregnancy and birth table
esttab  clust_lpm_pr_0 clust_lpm_pr_1 clust_d_pr_1  clust_lpm_br_0 clust_lpm_br_1  clust_d_br_1  using `results'/clust_main_w1_pregnant_birth.tex, replace ///
    indicate("Wave dummies = pass2 pass3 pass4" "Community dummies = *cluster*") ///
    s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
	nogap nolines varwidth(55) label ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) sfmt(0) ///
    drop(_cons assets_pc_wave1 *educ017* *agegroup*)	

// Contraceptive use table
esttab clust_lpm_ca_0 clust_lpm_ca_1 clust_d_ca_1  using `results'/clust_main_w1_contraceptives.tex, replace ///
    indicate("Wave dummies = pass2 pass3 pass4" "Community dummies = *cluster*") ///
    s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
	nogap nolines varwidth(55) label ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop(_cons assets_pc_wave1 *educ017* *agegroup*)

esttab clust_lpm_ct_0 clust_lpm_ct_1  clust_d_ct_1 using `results'/clust_main_w1_contraceptives.tex, append ///
    indicate("Wave dummies = pass2 pass3 pass4" "Community dummies = *cluster*") ///
    s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
	nogap nolines varwidth(55) label ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop(_cons assets_pc_wave1 *educ017* *agegroup*)

esttab clust_lpm_cm_0 clust_lpm_cm_1  clust_d_cm_1 using `results'/clust_main_w1_contraceptives.tex, append ///
    indicate("Wave dummies = pass2 pass3 pass4" "Community dummies = *cluster*") ///
    s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
	nogap nolines varwidth(55) label ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop(_cons assets_pc_wave1 *educ017* *agegroup*)	



// Full OLS tables 

esttab lpm_pr_0 lpm_pr_1 lpm_br_0 lpm_br_1  using `results'/ols_full_fertility_w1.tex, replace ///
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

esttab lpm_ca_0 lpm_ca_1 lpm_ct_0 lpm_ct_1 lpm_cm_0 lpm_cm_1 using `results'/ols_full_contraceptives_w1.tex, replace ///
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



// Add logit results to appendix tables

// esttab logit_c* using `results'/appendix_w1_contraceptive.tex, append ///
//     indicate(Wave dummies = pass2 pass3 pass4) ///
//     s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
// 	nogap nolines varwidth(55) label ///
// 	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) sfmt(0)
// 
// esttab logit_pr* logit_br*  using `results'/appendix_w1_pregnant_birth.tex, append ///
//     indicate(Wave dummies = pass2 pass3 pass4) ///
//     s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
// 	nogap nolines varwidth(55) label ///
// 	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) sfmt(0)

esttab logit_pr_1 logit_br_1 logit_c*_1 using `results'/appendix_w1_logit.tex, replace ///
    indicate(Wave dummies = pass2 pass3 pass4) ///
    s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
	nogap nolines varwidth(55) label ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) sfmt(0)

esttab logit_int_pr logit_int_br logit_int_c* using `results'/appendix_w1_logit.tex, append ///
    indicate(Wave dummies = pass2 pass3 pass4) ///
    s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
	nogap nolines varwidth(55) label ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) sfmt(0)



// Asset interactions

esttab d_int_pr d_int_br d_int_c* using `results'/main_w1_assets.tex, replace ///
    indicate(Wave dummies =  pass2 pass3 pass4) ///
    drop(_cons) ///
    stats(N N_g , fmt(0) label("Observations" "Number of women")) ///
	 nogap nolines varwidth(55) label ///
	 se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) sfmt(0)


// Age effects

esttab d_age_pr d_age_br d_age_c* using `results'/main_w1_age.tex, replace ///
    indicate(Wave dummies =  pass2 pass3 pass4) ///
    drop(_cons) ///
    varlabels( ///
    1.croplostdummy#16b.agegroup "Crop loss - 1-7 months (`strcut' TZS or above) - age 18-22" ///
    1.croplostdummy#23.agegroup "Crop loss - 1-7 months (`strcut' TZS or above) - age 23-27" ///
    1.croplostdummy#28.agegroup "Crop loss - 1-7 months (`strcut' TZS or above) - age 28-32" ///
    1.croplostdummy#33.agegroup "Crop loss - 1-7 months (`strcut' TZS or above) - age 33-37" ///
    1.croplostdummy#38.agegroup "Crop loss - 1-7 months (`strcut' TZS or above) - age 38-45" ///
    1.croplostdummy_lag#16b.agegroup "Crop loss - 7-14 months (`strcut' TZS or above) - age 18-22" ///
    1.croplostdummy_lag#23.agegroup "Crop loss - 7-14 months (`strcut' TZS or above) - age 23-27" ///
    1.croplostdummy_lag#28.agegroup "Crop loss - 7-14 months (`strcut' TZS or above) - age 28-32" ///
    1.croplostdummy_lag#33.agegroup "Crop loss - 7-14 months (`strcut' TZS or above) - age 33-37" ///
    1.croplostdummy_lag#38.agegroup "Crop loss - 7-14 months (`strcut' TZS or above) - age 38-45" ///
    ) ///
    s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
	nogap nolines varwidth(55) label ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) sfmt(0)

esttab logit_age* using `results'/main_w1_age_logit.tex, replace ///
    indicate(Wave dummies =  pass2 pass3 pass4) ///
    rename( ///
    1.croplostdummy_lag#16b.agegroup 1.croplostdummy#16b.agegroup ///
    1.croplostdummy_lag#23.agegroup 1.croplostdummy#23.agegroup  ///
    1.croplostdummy_lag#28.agegroup 1.croplostdummy#28.agegroup ///
    1.croplostdummy_lag#33.agegroup 1.croplostdummy#33.agegroup ///
    1.croplostdummy_lag#38.agegroup 1.croplostdummy#38.agegroup ///
    ) ///
    varlabels( ///
    1.croplostdummy#16b.agegroup "crop loss - age 18-22" ///
    1.croplostdummy#23.agegroup "crop loss - age 23-27" ///
    1.croplostdummy#28.agegroup "crop loss - age 28-32" ///
    1.croplostdummy#33.agegroup "crop loss - age 33-37" ///
    1.croplostdummy#38.agegroup "crop loss - age 38-45" ///
    ) ///
    stats(N N_g , fmt(0) label("Observations" "Number of women")) ///
	 nogap nolines varwidth(55) label ///
	 se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) sfmt(0)


////////////////////////////////////////////////////
// Looking at effect on traditional contraceptive //
////////////////////////////////////////////////////

eststo clear

// Not sure how best to estimate this. Mainly what we are looking to see
// is whether the effect comes mainly from abstinence

// All contraceptives with the exception of abstinence
// If you use other contraceptives than abstinence then you are still
// considered to be using contraceptives
gen excludeAbs = (method1 >= 2 & method1 <= 13) | (method2 >= 2 & method2 <= 13)
gen tradExcludeAbs = (method1 == 2 | method1 == 3) | (method2 == 2 | method2 == 3)
gen abstinence = method1 == 1 | method2 == 2

eststo exclude1: xtreg excludeAbs croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
eststo exclude2: xtreg excludeAbs croplostdummy croplostdummyXassets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
eststo exclude3: xtreg tradExcludeAbs croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
eststo exclude4: xtreg tradExcludeAbs croplostdummy croplostdummyXassets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
eststo exclude5: xtreg abstinence croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace
eststo exclude6: xtreg abstinence croplostdummy croplostdummyXassets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "Yes" , replace

esttab exclude* using `results'/noAbstinence_w1_contraceptives.tex, replace ///
    indicate(Wave dummies = pass2 pass3 pass4) ///
    s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
	nogap nolines varwidth(55) label ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop(_cons) 
    


////////////////////////////////////////////////////
// Effects of contraceptive use on pregnancy 	  //
////////////////////////////////////////////////////

eststo clear

// generate lagged contraceptive use
bysort id_woman (passage): gen lag_contra_any    = contra_any[_n-1]
bysort id_woman (passage): gen lag_contra_trad   = contra_trad[_n-1]
bysort id_woman (passage): gen lag_contra_modern = contra_modern[_n-1]

bysort id_woman (passage): gen numbirth2=numbirth[_n-1]


***Finding the effect traditional and modern contraceptive use 7 months ago on current pregnancy status:****
gen shockAny          = croplostdummy_lag * lag_contra_any
gen shockTraditional  = croplostdummy_lag * lag_contra_trad
gen shockModern       = croplostdummy_lag * lag_contra_modern
label variable shockAny         "Crop loss (7-14 months)  \X Any Contraceptive (7 months)"
label variable shockTraditional "Crop loss (7-14 months)  \X Traditional Contraceptive (7 months)"
label variable shockModern      "Crop loss (7-14 months)  \X Modern Contraceptive (7 months)"

loc xvar "pass3 pass4 numbirth2"
loc xvar "pass3 pass4 "
// loc xvar " "
*Finding the effect of tradional contraceptive use
eststo: xtreg pregnant lag_contra_any shockAny croplostdummy_lag `xvar', fe cluster(id_hh)

*Finding the effect of tradional contraceptive use
eststo: xtreg pregnant lag_contra_trad shockTraditional croplostdummy_lag `xvar', fe cluster(id_hh)

*Finding the effect of modern contraceptive use
eststo: xtreg pregnant lag_contra_modern shockModern croplostdummy_lag `xvar', fe cluster(id_hh)

esttab using `results'/effective.tex, replace ///
    indicate(Wave dummies =  pass3 pass4) ///
    drop(_cons) ///
    stats(N N_g , fmt(0) label("Observations" "Number of women")) ///
	nogap nolines varwidth(55) label ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) sfmt(0) ///
	rename( ///
	    lag_contra_trad   lag_contra_any ///
	    lag_contra_modern lag_contra_any ///
	    shockTraditional  shockAny ///
	    shockModern       shockAny ///
	    ) ///
	varlabels( ///
	    lag_contra_any  "Contraceptives (7 months)" ///
	    shockAny        "Crop loss (7-14 months)  \X Any Contraceptive (7 months)" ///
	    )

eststo clear




eststo clear

// Descriptive statistics

xi , noomit: estpost  sum assets_pc_wave1 i.educ017 i.agegroup if wave == 1 

esttab using `results'/desstat1.tex , ///
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


esttab using `results'/desstat2.tex , ///
    main(mean 2) aux(sd 2) nostar unstack ///
    varlabels( ///
        pregnant "Currently pregnant" ///
    ) ///
    nogap nolines varwidth(55) label ///
    noobs nonote nomtitle nonumber replace


exit


////////////////////////////////////////////////////
// Fixed effect LPM with dummy crop loss - using only 2, 3 and 4	  //
////////////////////////////////////////////////////

recode croplostdummy croplostdummy_lag (nonmissing = .) if wave == 1


// base specification without wave 1 asset interaction
eststo d_ca_1: xtreg contra_any croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
eststo d_ct_1: xtreg contra_trad croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
eststo d_cm_1: xtreg contra_mode croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
xtreg pregnant croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
xtreg pregnant croplostdummy_lag   pass3 pass4 , fe cluster(id_hh)
eststo d_pr_1: xtreg pregnant croplostdummy ///
	croplostdummy_lag  pass3 pass4 , fe cluster(id_hh)
eststo d_br_1: xtreg birth croplostdummy_lag  pass3 pass4 , fe cluster(id_hh)
xtreg birth croplostdummy_lag croplostdummy_lag2  pass4 , fe cluster(id_hh)



// base specification with interaction with wave 1 assets
eststo d_ca_2: xtreg contra_any croplostdummy croplostdummyXassets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
eststo d_ct_2: xtreg contra_trad croplostdummy croplostdummyXassets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
eststo d_cm_2: xtreg contra_mode croplostdummy croplostdummyXassets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
xtreg pregnant croplostdummy croplostdummyXassets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
xtreg pregnant croplostdummy_lag croplostdummy_lagXassets_w1  pass3 pass4 , fe cluster(id_hh)
eststo d_pr_2: xtreg pregnant croplostdummy croplostdummyXassets_w1 ///
	croplostdummy_lag croplostdummy_lagXassets_w1 pass3 pass4 , fe cluster(id_hh)
eststo d_br_2: xtreg birth croplostdummy_lag croplostdummy_lagXassets_w1  pass3 pass4 , fe cluster(id_hh)

// Age interaction
eststo d_age_ca: xtreg contra_any i1.croplostdummy#agegroup c.croplostdummyXassets_w1#agegroup pass2 pass3 pass4 , fe cluster(id_hh)
eststo d_age_ct: xtreg contra_trad i1.croplostdummy#agegroup c.croplostdummyXassets_w1#agegroup pass2 pass3 pass4 , fe cluster(id_hh)
// eststo d_age_cm: xtreg contra_mode i1.croplostdummy#agegroup c.croplostdummyXassets_w1#agegroup pass2 pass3 pass4 , fe cluster(id_hh)
eststo d_age_pr: xtreg pregnant i1.croplostdummy#agegroup c.croplostdummyXassets_w1#agegroup pass2 pass3 pass4 , fe cluster(id_hh)
xtreg pregnant i1.croplostdummy_lag#agegroup c.croplostdummy_lagXassets_w1#agegroup  pass3 pass4 , fe cluster(id_hh)
xtreg pregnant i1.croplostdummy#agegroup c.croplostdummyXassets_w1#agegroup ///
	i1.croplostdummy_lag#agegroup c.croplostdummy_lagXassets_w1#agegroup pass3 pass4 , fe cluster(id_hh)
eststo d_age_br: xtreg birth i1.croplostdummy_lag#agegroup c.croplostdummy_lagXassets_w1#agegroup pass3 pass4 , fe cluster(id_hh)




////////////////////////////////////////////
// Conditional fixed effects logit		  //
////////////////////////////////////////////

// base specification without wave 1 asset interaction
xtlogit contra_any croplostamount_pc  pass2 pass3 pass4 , fe 
xtlogit contra_trad croplostamount_pc  pass2 pass3 pass4 , fe 
xtlogit contra_mode croplostamount_pc  pass2 pass3 pass4 , fe 
xtlogit pregnant croplostamount_pc  pass2 pass3 pass4 , fe 
xtlogit pregnant croplostamount_pc_lag  pass3 pass4 , fe 
xtlogit pregnant croplostamount_pc croplostamount_pc_lag  pass3 pass4 , fe 
xtlogit birth croplostamount_pc_lag  pass3 pass4 , fe 

// base specification with interaction with wave 1 assets
xtlogit contra_any croplostamount_pc croplostXassets_w1 pass2 pass3 pass4 , fe 
xtlogit contra_trad croplostamount_pc croplostXassets_w1 pass2 pass3 pass4 , fe 
xtlogit contra_mode croplostamount_pc croplostXassets_w1 pass2 pass3 pass4 , fe 
xtlogit pregnant croplostamount_pc croplostXassets_w1 pass2 pass3 pass4 , fe 
xtlogit pregnant croplostamount_pc_lag croplost_lagXassets_w1  pass3 pass4 , fe 
xtlogit pregnant croplostamount_pc croplostXassets_w1 ///
	croplostamount_pc_lag croplost_lagXassets_w1 pass3 pass4 , fe 
xtlogit birth croplostamount_pc_lag croplost_lagXassets_w1  pass3 pass4 , fe 

// Age interaction
xtlogit contra_any c.croplostamount_pc#agegroup c.croplostXassets_w1#agegroup pass2 pass3 pass4 , fe 
xtlogit contra_trad c.croplostamount_pc#agegroup c.croplostXassets_w1#agegroup pass2 pass3 pass4 , fe 
// xtlogit contra_mode c.croplostamount_pc#agegroup c.croplostXassets_w1#agegroup pass2 pass3 pass4 , fe // Does not converge
xtlogit pregnant c.croplostamount_pc#agegroup c.croplostXassets_w1#agegroup pass2 pass3 pass4 , fe 
xtlogit pregnant c.croplostamount_pc_lag#agegroup c.croplost_lagXassets_w1#agegroup  pass3 pass4 , fe 
// xtlogit pregnant c.croplostamount_pc#agegroup c.croplostXassets_w1#agegroup ///
// 	c.croplostamount_pc_lag#agegroup c.croplost_lagXassets_w1#agegroup pass3 pass4 , fe // Does not converge
xtlogit birth c.croplostamount_pc_lag#agegroup c.croplost_lagXassets_w1#agegroup pass3 pass4 , fe 


    
    