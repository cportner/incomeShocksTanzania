// Main results with other time varying variables 
// an_timevarying.do

// Originally the idea was to have illness as an additional time varying
// variable in response to R1, but the problem with the illness variables 
// is that they only cover the last 4 weeks before the survey and that 
// illness is much more likely to be endogenous.

vers 13.1
clear
file close _all // makes working on code easier

//  short file paths - assuming work directory is "code"
loc data   "../data"
loc tables    "../tables"

use `data'/base

// data manipulation
include womenCommon 

gen priceact2 = priceact^2

bysort id_person (passage): gen pricefit_lag  = pricefit[_n-1]
bysort id_person (passage): gen priceact_lag  = priceact[_n-1]
bysort id_person (passage): gen priceact_lag2 = priceact[_n-2]
bysort id_person (passage): gen priceact2_lag = priceact2[_n-1]

// gen livestocklost_dummy = lvstlost > 1 & lvstlost < 200 // count of animals
gen livestocklost_dummy = livestocklost_amount > 200 & livestocklost_amount < 5000000 // value
bysort id_person (passage): gen livestocklost_dummy_lag = livestocklost_dummy[_n-1]

recode livestocklost_amount  (. = 0)
gen log_livestocklost = log(livestocklost_amount + 1)
bysort id_person (passage): gen log_livestocklost_lag = log_livestocklost[_n-1]

//////////////////////////////////////////////////////////////////////
// Fixed effect LPM Regressions with other time varying variables   //
//////////////////////////////////////////////////////////////////////

// Woman fixed effects base specification without wave 1 asset interaction
eststo d_ca_1: xtreg contra_any croplostdummy livestocklost_dummy priceact pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_ct_1: xtreg contra_trad croplostdummy  livestocklost_dummy priceact pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_cm_1: xtreg contra_mode croplostdummy  livestocklost_dummy priceact pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_pr_1: xtreg pregnant croplostdummy  livestocklost_dummy priceact pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_br_1: xtreg birth croplostdummy_lag livestocklost_dummy_lag priceact_lag pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace


/////////////////////////////////////////////////
// Tables                                      //
/////////////////////////////////////////////////

loc models "d_pr_1 d_br_1 d_ca_1 d_ct_1 d_cm_1"

file open table using `tables'/appendix_timevarying.tex, write replace
file write table "\begin{table}[htbp]" _n
file write table "\begin{center}" _n
file write table "\begin{small}" _n
file write table "\begin{threeparttable}" _n
file write table "\caption{The Effects of Other Time Varying Variables}" _n
file write table "\label{tab:timevarying}" _n
file write table "\begin{tabular}{@{} l D{.}{.}{2.6} D{.}{.}{2.6}  D{.}{.}{2.6} D{.}{.}{2.6} D{.}{.}{2.6}  @{}}" _n
file write table "\toprule" _n
file write table "                                                       & \mco{}              &\mco{}               &\multicolumn{3}{c}{Contraceptive Use}\\ \cmidrule(lr){4-6}" _n
file write table "                                                       & \mco{Pregnant}      &\mco{Birth}          &\mco{Any}            &\mco{Traditional}    & \mco{Modern}        \\ \midrule" _n
file close table

esttab `models' using `tables'/appendix_timevarying.tex, append ///
    fragment ///
	nogap nolines varwidth(55) label ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( _cons *pass* ) ///
    varlabels( ///
        livestocklost_dummy     "Livestock lost --- 1-7 months (200 TZS or above)\tnote{a}" ///
        livestocklost_dummy_lag "Livestock lost --- 7-14 months (200 TZS or above)" ///
        priceact                "Price index\tnote{b}" ///
        priceact_lag            "Price index prior survey" ///
    )
 
file open table using `tables'/appendix_timevarying.tex, write append
file write table "\addlinespace" _n 
file close table

esttab `models' using `tables'/appendix_timevarying.tex, append ///
    indicate("Wave dummies = pass2 pass3 pass4" , labels("\mco{Yes}" "\mco{No}")) ///
    s(fixed, label("Woman fixed effects")) ///
    fragment ///
	nogap nolines varwidth(55) label ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( _cons *croplost* price* live*)

// Observations / number of women
file open table using `tables'/appendix_timevarying.tex, write append
file write table "Observations" _col(56)
foreach res in `models'  {
    est restore `res'
    file write table "&    \mco{`e(N)'}        "
}
file write table "\\ " _n
file write table "Number of women" _col(56)
foreach res in `models' {
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
file write table "\item[a] Based on question 12.A.13: How many [animal name] raised by your household" _n
file write table "were lost or stolen, given a gifts, or died during the past 12 months." _n
file write table "\item[b] Price index as provide in the Kagera data. For a description" _n
file write table "of how it is calculated see \citet[Appendix II]{Development-Research-Group2004}." _n
file write table "\end{tablenotes}" _n
file write table "\end{threeparttable}" _n
file write table "\end{small}" _n
file write table "\end{center}" _n
file write table "\end{table}" _n
file close table

