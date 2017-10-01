// Main results by education levels of husband and wife
// anEducation.do

vers 13.1
clear
file close _all // makes working on code easier

//  short file paths - assuming work directory is "code"
loc data   "../data"
loc tables    "../tables"

use `data'/base

// data manipulation
include womenCommon 


//////////////////////////////////////////////////////////////////
// Fixed effect LPM Regressions with education interactions     //
//////////////////////////////////////////////////////////////////

//----------------------------------------------------------//
// Womens' education results                                //
//----------------------------------------------------------//

loc edu = "educ017"

// base specification with interaction with education
eststo wf_ca_2: xtreg contra_any i1.croplostdummy#`edu' pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo wf_ct_2: xtreg contra_trad i1.croplostdummy#`edu' pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo wf_cm_2: xtreg contra_mode i1.croplostdummy#`edu' pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo wf_pr_2: xtreg pregnant i1.croplostdummy#`edu' pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo wf_br_2: xtreg birth i1.croplostdummy_lag#`edu'  pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace


//----------------------------------------------------------//
// Spouses' education results                                //
//----------------------------------------------------------//

loc edu = "sp_educ017"

// Drop those without husband education information for all waves
tempvar edu_count
bysort id_person (wave): egen `edu_count' = count(`edu')
keep if `edu_count' == 4


// base specification with interaction with education
eststo hb_ca_2: xtreg contra_any i1.croplostdummy#`edu' pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo hb_ct_2: xtreg contra_trad i1.croplostdummy#`edu' pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo hb_cm_2: xtreg contra_mode i1.croplostdummy#`edu' pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo hb_pr_2: xtreg pregnant i1.croplostdummy#`edu' pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo hb_br_2: xtreg birth i1.croplostdummy_lag#`edu'  pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace


/////////////////////////////////////////////////
// Tables                                      //
/////////////////////////////////////////////////

file open table using `tables'/appendix_education.tex, write replace
file write table "\begin{table}[htbp]" _n
file write table "\begin{center}" _n
file write table "\begin{small}" _n
file write table "\begin{threeparttable}" _n
file write table "\caption{The Effects of Crop Loss on Contraceptives Use by Education Level}" _n
file write table "\label{tab:education}" _n
file write table "\begin{tabular}{@{} l D{.}{.}{2.6} D{.}{.}{2.6}  D{.}{.}{2.6} D{.}{.}{2.6} D{.}{.}{2.6}  @{}}" _n
file write table "\toprule" _n
file write table "                                                       & \mco{}              &\mco{}               &\multicolumn{3}{c}{Contraceptive Use}\\ \cmidrule(lr){4-6}" _n
file write table "                                                       & \mco{Pregnant}      &\mco{Birth}          &\mco{Any}            &\mco{Traditional}    & \mco{Modern}        \\ \midrule" _n
file write table "                                                       & \multicolumn{5}{c}{Respondent's education level} \\" _n
file close table

// Womens' education
esttab wf_pr_2 wf_br_2 wf_ca_2 wf_ct_2 wf_cm_2 using `tables'/appendix_education.tex, append ///
    fragment ///
	nogap nolines varwidth(55)  ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( _cons *pass* ) ///
    varlabels( ///
        1.croplostdummy#0.educ017       "Crop loss \X no education" ///
        1.croplostdummy#1.educ017       "Crop loss \X 1-6 years of education" ///
        1.croplostdummy#7.educ017       "Crop loss \X 7+ years of education" ///
        1.croplostdummy_lag#0.educ017   "Crop loss lagged \X no education" ///
        1.croplostdummy_lag#1.educ017   "Crop loss lagged \X 1-6 years of education" ///
        1.croplostdummy_lag#7.educ017   "Crop loss lagged \X 7+ years of education" ///
    )    


file open table using `tables'/appendix_education.tex, write append
file write table "\addlinespace" _n 
file close table

esttab wf_pr_2 wf_br_2 wf_ca_2 wf_ct_2 wf_cm_2 using `tables'/appendix_education.tex, append ///
    indicate("Wave dummies = pass2 pass3 pass4" , labels("\mco{Yes}" "\mco{No}")) ///
    s(fixed, label("Woman fixed effects")) ///
    fragment ///
	nogap nolines varwidth(55) label ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( _cons *croplost*)

// Observations / number of women
file open table using `tables'/appendix_education.tex, write append
file write table "Observations" _col(56)
foreach res in wf_pr_2 wf_br_2 wf_ca_2 wf_ct_2 wf_cm_2  {
    est restore `res'
    file write table "&    \mco{`e(N)'}        "
}
file write table "\\ " _n
file write table "Number of women" _col(56)
foreach res in wf_pr_2 wf_br_2 wf_ca_2 wf_ct_2 wf_cm_2 {
    est restore `res'
    loc numWomen = `e(N_g)'
    file write table "&    \mco{`numWomen'}        "
}
file write table "\\ " _n


// Husbands' education results
file write table "\addlinespace" _n
file write table "                                                       & \multicolumn{5}{c}{Husbands' education level} \\" _n
file close table


esttab hb_pr_2 hb_br_2 hb_ca_2 hb_ct_2 hb_cm_2 using `tables'/appendix_education.tex, append ///
    fragment ///
	nogap nolines varwidth(55)  ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( _cons *pass* ) ///
    varlabels( ///
        1.croplostdummy#0.sp_educ017       "Crop loss \X no education" ///
        1.croplostdummy#1.sp_educ017       "Crop loss \X 1-6 years of education" ///
        1.croplostdummy#7.sp_educ017       "Crop loss \X 7+ years of education" ///
        1.croplostdummy_lag#0.sp_educ017   "Crop loss lagged \X no education" ///
        1.croplostdummy_lag#1.sp_educ017   "Crop loss lagged \X 1-6 years of education" ///
        1.croplostdummy_lag#7.sp_educ017   "Crop loss lagged \X 7+ years of education" ///
    )    


file open table using `tables'/appendix_education.tex, write append
file write table "\addlinespace" _n 
file close table

esttab hb_pr_2 hb_br_2 hb_ca_2 hb_ct_2 hb_cm_2 using `tables'/appendix_education.tex, append ///
    indicate("Wave dummies = pass2 pass3 pass4" , labels("\mco{Yes}" "\mco{No}")) ///
    s(fixed, label("Woman fixed effects")) ///
    fragment ///
	nogap nolines varwidth(55) label ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( _cons *croplost*)

// Observations / number of women
file open table using `tables'/appendix_education.tex, write append
file write table "Observations" _col(56)
foreach res in hb_pr_2 hb_br_2 hb_ca_2 hb_ct_2 hb_cm_2  {
    est restore `res'
    file write table "&    \mco{`e(N)'}        "
}
file write table "\\ " _n
file write table "Number of women" _col(56)
foreach res in hb_pr_2 hb_br_2 hb_ca_2 hb_ct_2 hb_cm_2 {
    est restore `res'
    loc numWomen = `e(N_g)'
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
file write table "Crop loss is a dummy for a per capita crop loss of `labCroploss'." _n
file write table "Women for whom we do not have information on the education of their " _n
file write table "husband/partner are dropped for the lower panel." _n
file write table "\end{tablenotes}" _n
file write table "\end{threeparttable}" _n
file write table "\end{small}" _n
file write table "\end{center}" _n
file write table "\end{table}" _n
file close table

