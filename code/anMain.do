// Main results
// anMain.do

vers 13.1
clear
file close _all // makes working on code easier

//  short file paths - assuming work directory is "code"
loc data   "../data"
loc tables    "../tables"

use `data'/base

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

file open table using `tables'/main_pregnant_birth.tex, write replace
file write table "\begin{table}[htbp]" _n
file write table "\begin{center}" _n
file write table "\begin{threeparttable}" _n
file write table "\caption{The Effects of Crop Loss on Pregnancy and Births}" _n
file write table "\label{tab:birth}" _n
file write table "\begin{tabular}{@{} l D{.}{.}{1.5} D{.}{.}{1.5} D{.}{.}{1.5} D{.}{.}{1.5} D{.}{.}{1.5} D{.}{.}{1.5}  @{}}" _n
file write table "\toprule" _n
file write table "                             &\multicolumn{3}{c}{Currently pregnant}&\multicolumn{3}{c}{Birth since last survey}\\ \cmidrule(lr){2-4} \cmidrule(lr){5-7}" _n
file write table "                             &                     & \mct{Fixed Effects}                       &                     & \mct{Fixed Effects}                       \\ \cmidrule(lr){3-4} \cmidrule(lr){6-7}" _n
file write table "                             & \mco{OLS}           & \mco{Community}     & \mco{Woman}         & \mco{OLS}           & \mco{Community}     & \mco{Woman}         \\ \midrule" _n
file write table "Crop loss - 1-7 months" _col(30)
foreach res in lpm_pr_0    {
    est restore `res'
    qui reg
    matrix rtable = r(table)
    matrix list rtable
    file write table "&  " %6.3f (_b[croplostdummy])
    // significance stars
//     loc t = A["pvalue","croplostdummy"]
}
file close table
exit

 matrix A = rtable["pvalue", "croplostdummy"]

. matrix list A

symmetric A[1,1]
        croplostdu~y
pvalue      .1116369

. local test = rtable["pvalue", "croplostdummy"]
matrix operators that return matrices not allowed in this context
r(509);

. local test = rtable[4,1]

. dis `test'
.1116369

. local test = A[1,1]

. dis `test'
.1116369



esttab  lpm_pr_0 lpm_pr_1 d_pr_1  lpm_br_0 lpm_br_1  d_br_1  using `tables'/main_pregnant_birth.tex, append ///
    indicate("Wave dummies = pass2 pass3 pass4" "Community dummies = *cluster*") ///
    s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
	nogap nolines varwidth(55) label ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) sfmt(0) ///
    drop(_cons assets_pc_wave1 *educ017* *agegroup*)	
    
exit    
    

// Contraceptive use table
esttab lpm_ca_0 lpm_ca_1 d_ca_1  using `tables'/main_w1_contraceptives.tex, replace ///
    indicate("Wave dummies = pass2 pass3 pass4" "Community dummies = *cluster*") ///
    s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
	nogap nolines varwidth(55) label ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop(_cons assets_pc_wave1 *educ017* *agegroup*)

esttab lpm_ct_0 lpm_ct_1  d_ct_1 using `tables'/main_w1_contraceptives.tex, append ///
    indicate("Wave dummies = pass2 pass3 pass4" "Community dummies = *cluster*") ///
    s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
	nogap nolines varwidth(55) label ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop(_cons assets_pc_wave1 *educ017* *agegroup*)

esttab lpm_cm_0 lpm_cm_1  d_cm_1 using `tables'/main_w1_contraceptives.tex, append ///
    indicate("Wave dummies = pass2 pass3 pass4" "Community dummies = *cluster*") ///
    s(fixed N N_g, fmt(0) label("Woman fixed effects" "Observations" "Number of women"))  ///
	nogap nolines varwidth(55) label ///
	se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop(_cons assets_pc_wave1 *educ017* *agegroup*)	



// Full OLS tables 

esttab lpm_pr_0 lpm_pr_1 lpm_br_0 lpm_br_1  using `tables'/ols_full_fertility_w1.tex, replace ///
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

esttab lpm_ca_0 lpm_ca_1 lpm_ct_0 lpm_ct_1 lpm_cm_0 lpm_cm_1 using `tables'/ols_full_contraceptives_w1.tex, replace ///
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


