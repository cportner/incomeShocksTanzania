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
// Fixed effect on hours worked and crop loss                   //
//////////////////////////////////////////////////////////////////

eststo: xtreg hrs croplostdummy pass2 pass3 pass4, fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo: xtreg hrs croplostdummy croplostdummyXassets_w1 pass2 pass3 pass4,  fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo: xtreg hrs ln_croplostamount_pc pass2 pass3 pass4, fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo: xtreg hrs ln_croplostamount_pc ln_croplostXassets_w1 pass2 pass3 pass4, fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo: xtreg hrs ln_croplostamount_pc ln_croplostXln_assets_w1 pass2 pass3 pass4, fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace



/////////////////////////////////////////////////
// Tables                                      //
/////////////////////////////////////////////////

file open table using `tables'/appendix_hours.tex, write replace
file write table "\begin{table}[htbp]" _n
file write table "\begin{center}" _n
file write table "\begin{small}" _n
file write table "\begin{threeparttable}" _n
file write table "\caption{Crop loss and Hours Worked per Week for Women}" _n
file write table "\label{tab:hours}" _n
file write table "\begin{tabular}{@{} l D{.}{.}{2.6} D{.}{.}{2.6}  D{.}{.}{2.6} D{.}{.}{2.6} D{.}{.}{2.6}  @{}}" _n
file write table "\toprule" _n
file write table "                                                       &\multicolumn{5}{c}{Hours worked by woman} \\ \midrule " _n
file close table

esttab  using `tables'/appendix_hours.tex, append ///
    fragment ///
	nogap nolines varwidth(55)  ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( _cons *pass* ) ///
    varlabels( ///
    )

exit

file open table using `tables'/appendix_hours.tex, write append
file write table "\addlinespace" _n 
file close table

esttab d_age_pr d_age_br d_age_ca d_age_ct d_age_cm using `tables'/appendix_hours.tex, append ///
    indicate("Wave dummies = pass2 pass3 pass4" , labels("\mco{Yes}" "\mco{No}")) ///
    s(fixed, label("Woman fixed effects")) ///
    fragment ///
	nogap nolines varwidth(55)  ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( _cons *croplost*)

// Observations / number of women
file open table using `tables'/appendix_hours.tex, write append
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

