// Does village crop loss affect decisions
// anVillage.do

vers 13.1
clear
file close _all // makes working on code easier

//  short file paths - assuming work directory is "code"
loc data   "../data"
loc tables    "../tables"

use `data'/base

//////////////////////////////
// Village level crop loss  //
//////////////////////////////

// // This includes the household in the mean
// preserve 
// tempfile village
// 
// // Create dummy crop loss (from womenCommon.do)
// loc divide = 10000
// loc strdiv "10,000"
// loc cutoff = 200/`divide' // Remember to change this if we re-do units in crBase.do
// gen croplostdummy = croplostamount_pc >= `cutoff' if croplostamount_pc != .
// 
// collapse (mean) croplostdummy , by(cluster hh passage) // only one obs per household needed
// collapse (mean) croplostdummy , by(cluster passage)
// rename croplostdummy village_croplost
// bysort cluster (passage): gen village_croplost_lag = village_croplost[_n-1]
// keep cluster passage village_croplost village_croplost_lag
// save `village'
// 
// restore
// merge m:1 cluster passage using `village'
// drop _merge

// Excluding the household from the ratio of households that have lost crops
preserve 
tempfile village
tempvar totalcroploss numHouseholds
// Create dummy crop loss (from womenCommon.do)
loc divide = 10000
loc strdiv "10,000"
loc cutoff = 200/`divide' // Remember to change this if we re-do units in crBase.do
gen croplostdummy = croplostamount_pc >= `cutoff' if croplostamount_pc != .
bysort id_hh passage: keep if _n == 1  // only one obs per household needed
drop if croplostdummy == .

egen `totalcroploss' = total(croplostdummy), by(cluster passage)
replace `totalcroploss' = `totalcroploss' - croplostdummy
bysort cluster passage: gen `numHouseholds' = _N
gen village_croplost = `totalcroploss' / (`numHouseholds' - 1)

bysort id_hh (passage): gen village_croplost_lag = village_croplost[_n-1]
keep id_hh passage village_croplost village_croplost_lag
save `village'

restore
merge m:1 id_hh passage using `village'

sort id_person // needed for "womenCommon" to work

// regular data manipulation
do womenCommon 

label variable village_croplost     "Fraction with crop loss in village"
label variable village_croplost_lag "Lagged fraction with crop loss in village"



////////////////////////////////////////////////////////////////////////
// Does croploss of other households in the village affects results?  //
////////////////////////////////////////////////////////////////////////


eststo vil_pr: xtreg pregnant croplostdummy  pass2 pass3 pass4 village_croplost, fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo vil_br: xtreg birth croplostdummy_lag  pass3 pass4 village_croplost_lag , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo vil_ca: xtreg contra_any croplostdummy  pass2 pass3 pass4 village_croplost, fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo vil_ct: xtreg contra_trad croplostdummy  pass2 pass3 pass4 village_croplost, fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo vil_cm: xtreg contra_mode croplostdummy  pass2 pass3 pass4 village_croplost, fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace



/////////////////////////////////////////////////
// Tables                                      //
/////////////////////////////////////////////////

file open table using `tables'/appendix_village.tex, write replace
file write table "\begin{table}[htbp]" _n
file write table "\begin{center}" _n
file write table "\begin{small}" _n
file write table "\begin{threeparttable}" _n
file write table "\caption{The Effects of Individual and Village Crop Loss}" _n
file write table "\label{tab:vill_croploss}" _n
file write table "\begin{tabular}{@{} l D{.}{.}{2.6} D{.}{.}{2.6}  D{.}{.}{2.6} D{.}{.}{2.6} D{.}{.}{2.6}  @{}}" _n
file write table "\toprule" _n
file write table "                                                       & \mco{}              &\mco{}               &\multicolumn{3}{c}{Contraceptive Use}\\ \cmidrule(lr){4-6}" _n
file write table "                                                       & \mco{Pregnant}      &\mco{Birth}          &\mco{Any}            &\mco{Traditional}    & \mco{Modern}        \\ \midrule" _n
file close table

// Womens' education
esttab vil_* using `tables'/appendix_village.tex, append ///
    fragment ///
	nogap nolines varwidth(55)  ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( _cons *pass* ) ///
    varlabels( ///
    )    

file open table using `tables'/appendix_village.tex, write append
file write table "\addlinespace" _n 
file close table

esttab vil_* using `tables'/appendix_village.tex, append ///
    indicate("Wave dummies = pass2 pass3 pass4" , labels("\mco{Yes}" "\mco{No}")) ///
    s(fixed, label("Woman fixed effects")) ///
    fragment ///
	nogap nolines varwidth(55) label ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( _cons *croplost*)

// Observations / number of women
file open table using `tables'/appendix_village.tex, write append
file write table "Observations" _col(56)
foreach res in vil_pr vil_br vil_ca vil_ct vil_cm  {
    est restore `res'
    file write table "&    \mco{`e(N)'}        "
}
file write table "\\ " _n
file write table "Number of women" _col(56)
foreach res in vil_pr vil_br vil_ca vil_ct vil_cm {
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
file write table "Crop loss is a dummy for a per capita crop loss of 200 TZS or above." _n
file write table "\end{tablenotes}" _n
file write table "\end{threeparttable}" _n
file write table "\end{small}" _n
file write table "\end{center}" _n
file write table "\end{table}" _n
file close table

