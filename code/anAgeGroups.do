// Main results by age group
// anAgeGroups.do

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

//////////////////////////////////////////////////////////////////
// Fixed effect LPM Regressions by Age Groups                   //
//////////////////////////////////////////////////////////////////

// Age interaction
eststo d_age_ca: xtreg contra_any i1.croplostdummy#agegroup  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_age_ct: xtreg contra_trad i1.croplostdummy#agegroup  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_age_cm: xtreg contra_mode i1.croplostdummy#agegroup  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_age_pr: xtreg pregnant i1.croplostdummy#agegroup  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_age_br: xtreg birth i1.croplostdummy_lag#agegroup  pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace


/////////////////////////////////////////////////
// Tables                                      //
/////////////////////////////////////////////////

file open table using `tables'/appendix_age_groups.tex, write replace
file write table "\begin{table}[htbp]" _n
file write table "\begin{center}" _n
file write table "\begin{small}" _n
file write table "\begin{threeparttable}" _n
file write table "\caption{The Effects of Crop Loss by Age}" _n
file write table "\label{tab:agegroups}" _n
file write table "\begin{tabular}{@{} l D{.}{.}{2.6} D{.}{.}{2.6}  D{.}{.}{2.6} D{.}{.}{2.6} D{.}{.}{2.6}  @{}}" _n
file write table "\toprule" _n
file write table "                                                       & \mco{}              &\mco{}               &\multicolumn{3}{c}{Contraceptive Use}\\ \cmidrule(lr){4-6}" _n
file write table "                                                       & \mco{Pregnant}      &\mco{Birth}          &\mco{Any}            &\mco{Traditional}    & \mco{Modern}        \\ \midrule" _n
file close table

esttab d_age_pr d_age_br d_age_ca d_age_ct d_age_cm using `tables'/appendix_age_groups.tex, append ///
    fragment ///
	nogap nolines varwidth(55)  ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( _cons *pass* ) ///
    varlabels( ///
        1.croplostdummy#12.agegroup "Crop loss --- 1-7 months \X age 18-22" ///
        1.croplostdummy#23.agegroup "Crop loss --- 1-7 months \X age 23-27" ///
        1.croplostdummy#28.agegroup "Crop loss --- 1-7 months \X age 28-32" ///
        1.croplostdummy#33.agegroup "Crop loss --- 1-7 months \X age 33-37" ///
        1.croplostdummy#38.agegroup "Crop loss --- 1-7 months \X age 38-45" ///
        1.croplostdummy_lag#12.agegroup "Crop loss --- 7-14 months \X age 18-22" ///
        1.croplostdummy_lag#23.agegroup "Crop loss --- 7-14 months \X age 23-27" ///
        1.croplostdummy_lag#28.agegroup "Crop loss --- 7-14 months \X age 28-32" ///
        1.croplostdummy_lag#33.agegroup "Crop loss --- 7-14 months \X age 33-37" ///
        1.croplostdummy_lag#38.agegroup "Crop loss --- 7-14 months \X age 38-45" ///
    )
 

file open table using `tables'/appendix_age_groups.tex, write append
file write table "\addlinespace" _n 
file close table

esttab d_age_pr d_age_br d_age_ca d_age_ct d_age_cm using `tables'/appendix_age_groups.tex, append ///
    indicate("Wave dummies = pass2 pass3 pass4" , labels("\mco{Yes}" "\mco{No}")) ///
    s(fixed, label("Woman fixed effects")) ///
    fragment ///
	nogap nolines varwidth(55)  ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( _cons *croplost*)

// Observations / number of women
file open table using `tables'/appendix_age_groups.tex, write append
file write table "Observations" _col(56)
foreach res in d_age_pr d_age_br d_age_ca d_age_ct d_age_cm  {
    est restore `res'
    file write table "&    \mco{`e(N)'}        "
}
file write table "\\ " _n
file write table "Number of women" _col(56)
foreach res in d_age_pr d_age_br d_age_ca d_age_ct d_age_cm {
    est restore `res'
    if "`e(depvar)'" == "pregnant" | "`e(depvar)'" == "contra_any" | "`e(depvar)'" == "contra_trad" | "`e(depvar)'" == "contra_modern" {
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
file write table "Age groups is based on age at the first round of the survey as described in the text." _n
file write table "\end{tablenotes}" _n
file write table "\end{threeparttable}" _n
file write table "\end{small}" _n
file write table "\end{center}" _n
file write table "\end{table}" _n
file close table

