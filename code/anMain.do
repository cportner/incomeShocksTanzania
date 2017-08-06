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
estadd local fixed "\mco{No}" , replace
eststo lpm_ct_0: reg contra_trad croplostdummy  pass2 pass3 pass4 `xvar', cluster(id_hh)
estadd local fixed "\mco{No}" , replace
eststo lpm_cm_0: reg contra_mode croplostdummy  pass2 pass3 pass4 `xvar', cluster(id_hh)
estadd local fixed "\mco{No}" , replace
eststo lpm_pr_0: reg pregnant croplostdummy  pass2 pass3 pass4 `xvar', cluster(id_hh)
estadd local fixed "\mco{No}" , replace
eststo lpm_br_0: reg birth croplostdummy_lag  pass3 pass4 `xvar', cluster(id_hh)
estadd local fixed "\mco{No}" , replace

// Community fixed effects - base specification without wave 1 asset interaction
loc xvar = " assets_pc_wave1 i.educ017 i.agegroup i.cluster"
eststo lpm_ca_1: reg contra_any croplostdummy  pass2 pass3 pass4 `xvar', cluster(id_hh)
estadd local fixed "\mco{No}" , replace
eststo lpm_ct_1: reg contra_trad croplostdummy  pass2 pass3 pass4 `xvar', cluster(id_hh)
estadd local fixed "\mco{No}" , replace
eststo lpm_cm_1: reg contra_mode croplostdummy  pass2 pass3 pass4 `xvar', cluster(id_hh)
estadd local fixed "\mco{No}" , replace
eststo lpm_pr_1: reg pregnant croplostdummy  pass2 pass3 pass4 `xvar', cluster(id_hh)
estadd local fixed "\mco{No}" , replace
eststo lpm_br_1: reg birth croplostdummy_lag  pass3 pass4 `xvar', cluster(id_hh)
estadd local fixed "\mco{No}" , replace

// Woman fixed effects base specification without wave 1 asset interaction
eststo d_ca_1: xtreg contra_any croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_ct_1: xtreg contra_trad croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_cm_1: xtreg contra_mode croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_pr_1: xtreg pregnant croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_br_1: xtreg birth croplostdummy_lag  pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace



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
// Pregnancy
file write table "Crop loss --- 1-7 months" _col(30)
foreach res in lpm_pr_0  lpm_pr_1 d_pr_1  {
    est restore `res'
    qui `e(cmd)' // Stata does not provide access to r(table) unless results displayed again
    matrix rtable = r(table)
    file write table "&      " %6.3f (_b[croplostdummy])
    // significance stars
    matrix P = rtable["pvalue","croplostdummy"]
    loc p = P[1,1] // This is just stupid, but Stata does not allow extraction to local using column/row names
    if `p' < 0.01 {
        file write table "^{***}   "
    }
    else if `p' < 0.05 & `p' >= 0.01 {
        file write table "^{**}    "
    }
    else if `p' < 0.10 & `p' >= 0.05 {
        file write table "^{*}     "
    }
    else {
        file write table "         "
    }
}
file write table "&                     &                     &                     \\ " _n
file write table "\hs (200 TZS or above)" _col(30)
foreach res in lpm_pr_0  lpm_pr_1 d_pr_1  {
    est restore `res'
    qui `e(cmd)' 
    matrix rtable = r(table)
    file write table "&      (" %5.3f (_se[croplostdummy]) ")        "
}
file write table "&                     &                     &                     \\ " _n
// Births 
file write table "Crop loss --- 7-14 months" _col(30)
file write table "&                     &                     &                     " 
foreach res in lpm_br_0 lpm_br_1  d_br_1  {
    est restore `res'
    qui `e(cmd)' 
    matrix rtable = r(table)
    file write table "&      " %6.3f (_b[croplostdummy_lag])
    // significance stars
    matrix P = rtable["pvalue","croplostdummy_lag"]
    loc p = P[1,1] // This is just stupid, but Stata does not allow extraction to local using column/row names
    if `p' < 0.01 {
        file write table "^{***}   "
    }
    else if `p' < 0.05 & `p' >= 0.01 {
        file write table "^{**}    "
    }
    else if `p' < 0.10 & `p' >= 0.05 {
        file write table "^{*}     "
    }
    else {
        file write table "         "
    }
}
file write table "\\ " _n
file write table "\hs (200 TZS or above)" _col(30)
file write table "&                     &                     &                     " 
foreach res in lpm_br_0 lpm_br_1  d_br_1  {
    est restore `res'
    qui `e(cmd)' 
    matrix rtable = r(table)
    file write table "&      (" %5.3f (_se[croplostdummy_lag]) ")        "
}
file write table "\\ " _n
// Dummy / fixed effects indicators
file write table "Wave dummies                 &    \mco{Yes}        &    \mco{Yes}        &    \mco{Yes}        &    \mco{Yes}        &    \mco{Yes}        &    \mco{Yes}        \\" _n
file write table "Community fixed effects      &    \mco{No}         &    \mco{Yes}        &    \mco{No}         &    \mco{No}         &    \mco{Yes}        &    \mco{No}         \\" _n
file write table "Woman fixed effects          &    \mco{No}         &    \mco{No}         &    \mco{Yes}        &    \mco{No}         &    \mco{No}         &    \mco{Yes}        \\" _n
// Observations / number of women
file write table "Observations" _col(30)
foreach res in lpm_pr_0 lpm_pr_1 d_pr_1 lpm_br_0 lpm_br_1  d_br_1  {
    est restore `res'
    file write table "&    \mco{`e(N)'}        "
}
file write table "\\ " _n
file write table "Number of women" _col(30)
foreach res in lpm_pr_0 lpm_pr_1 d_pr_1 lpm_br_0 lpm_br_1  d_br_1  {
    est restore `res'
    if "`e(depvar)'" == "pregnant" {
        loc numWomen = `e(N)' /  4
    }
    else {
        loc numWomen = `e(N)' / 3 
    }
    file write table "&    \mco{`numWomen'}        "
}
file write table "\\ " _n
file write table "\bottomrule" _n
file write table "\end{tabular}" _n
file write table "\begin{tablenotes} \footnotesize" _n
file write table "\item \hspace*{-0.5em} \textbf{Note.}" _n
file write table "All models are linear probability models." _n
file write table "Robust standard errors clustered at household level in parentheses; " _n
file write table "* significant at 10\%; ** significant at 5\%; *** significant at 1\%." _n
file write table "Crop loss is a dummy for a per capita crop loss of 200 TZS or above." _n
file write table "% Assets are per capita and measured in 10,000 TZS." _n
file write table "\end{tablenotes}" _n
file write table "\end{threeparttable}" _n
file write table "\end{center}" _n
file write table "\end{table}" _n
file close table



    

// Contraceptive use table

file open table using `tables'/main_contraceptives.tex, write replace
file write table "\begin{table}[htbp]" _n
file write table "\begin{center}" _n
file write table "\begin{threeparttable}" _n
file write table "\caption{The Effects of Crop Loss on Contraceptive\\ Use Overall and By Type}" _n
file write table "\label{tab:contraceptive}" _n
file write table "\begin{tabular}{@{} l D{.}{.}{2.6}  D{.}{.}{2.6} D{.}{.}{2.6}  @{}}" _n
file write table "\toprule" _n
file write table "                                                       &                     & \mct{Fixed Effects}                       \\ \cmidrule(lr){3-4} " _n
file write table "                                                       & \mco{OLS}           & \mco{Community}     & \mco{Woman}         \\ \midrule" _n
file write table "                                                       &\multicolumn{3}{c}{Any contraception}  \\ \cmidrule(lr){2-4}" _n

file close table

esttab lpm_ca_0 lpm_ca_1 d_ca_1  using `tables'/main_contraceptives.tex, append ///
    fragment ///
	nogap nolines varwidth(55) label ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop(_cons assets_pc_wave1 *educ017* *agegroup* *pass* *clust*)

file open table using `tables'/main_contraceptives.tex, write append
file write table "\addlinespace" _n
file write table _col(56) "&\multicolumn{3}{c}{Traditional contraception}  \\ \cmidrule(lr){2-4} " _n
file close table

esttab lpm_ct_0 lpm_ct_1  d_ct_1 using `tables'/main_contraceptives.tex, append ///
    fragment ///
	nogap nolines varwidth(55) label ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop(_cons assets_pc_wave1 *educ017* *agegroup* *pass* *clust*)

file open table using `tables'/main_contraceptives.tex, write append
file write table "\addlinespace" _n
file write table _col(56) "&\multicolumn{3}{c}{Modern contraception}  \\ \cmidrule(lr){2-4} " _n
file close table

esttab lpm_cm_0 lpm_cm_1  d_cm_1 using `tables'/main_contraceptives.tex, append ///
    fragment ///
	nogap nolines varwidth(55) label ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop(_cons assets_pc_wave1 *educ017* *agegroup* *pass* *clust*)

file open table using `tables'/main_contraceptives.tex, write append
file write table "\addlinespace" _n
file close table

esttab lpm_cm_0 lpm_cm_1  d_cm_1 using `tables'/main_contraceptives.tex, append ///
    indicate("Wave dummies = pass2 pass3 pass4" "Community dummies = *cluster*", labels("\mco{Yes}" "\mco{No}")) ///
    s(fixed, label("Woman fixed effects")) ///
    fragment ///
	nogap nolines varwidth(55) label ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop(_cons assets_pc_wave1 *educ017* *agegroup* croplost*)

// Observations / number of women
file open table using `tables'/main_contraceptives.tex, write append
file write table "Observations" _col(56)
foreach res in lpm_cm_0 lpm_cm_1  d_cm_1  {
    est restore `res'
    file write table "&    \mco{`e(N)'}        "
}
file write table "\\ " _n
file write table "Number of women" _col(56)
foreach res in lpm_cm_0 lpm_cm_1  d_cm_1 {
    est restore `res'
    loc numWomen = `e(N)' /  4
    file write table "&    \mco{`numWomen'}        "
}
file write table "\\ " _n
file write table "\bottomrule" _n
file write table "\end{tabular}" _n
file write table "\begin{tablenotes} \footnotesize" _n
file write table "\item \hspace*{-0.5em} \textbf{Note.}" _n
file write table "All models are linear probability models." _n
file write table "Robust standard errors clustered at household level in parentheses; " _n
file write table "* significant at 10\%; ** significant at 5\%; *** significant at 1\%." _n
file write table "Crop loss is a dummy for a per capita crop loss of 200 TZS or above." _n
file write table "% Assets are per capita and measured in 10,000 TZS." _n
file write table "\end{tablenotes}" _n
file write table "\end{threeparttable}" _n
file write table "\end{center}" _n
file write table "\end{table}" _n
file close table

exit


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


