// Main results
// anMain.do

vers 13.1
clear

//  short file paths - assuming work directory is "code"
loc dataDir   "../data"
loc resDir    "../tables"

use `dataDir'/base

// data manipulation
do womenCommon 

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

    