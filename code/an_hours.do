// Effects of crop loss on hours worked 
// anHours.do

vers 13.1
clear
file close _all // makes working on code easier

//  short file paths - assuming work directory is "code"
loc data   "../data"
loc tables    "../tables"

use `data'/base

// data manipulation
include womenCommon 

//////////////////////////////
// Results for Main results //
//////////////////////////////

//////////////////////////////////////////////////////////////////
// Fixed effect on hours worked and crop loss                   //
//////////////////////////////////////////////////////////////////

eststo clear
eststo reg1: xtreg hours croplostdummy pass2 pass3 pass4, fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo reg2: xtreg hours croplostdummy croplostdummyXassets_w1 pass2 pass3 pass4,  fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo reg3: xtreg hours ln_croplostamount_pc pass2 pass3 pass4, fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo reg4: xtreg hours ln_croplostamount_pc ln_croplostXassets_w1 pass2 pass3 pass4, fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo reg5: xtreg hours ln_croplostamount_pc ln_croplostXln_assets_w1 pass2 pass3 pass4, fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace



/////////////////////////////////////////////////
// Tables                                      //
/////////////////////////////////////////////////

loc models "reg1 reg3"

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

esttab `models' using `tables'/appendix_hours.tex, append ///
    fragment ///
	nogap nolines varwidth(55) label ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( _cons *pass* ) ///
    varlabels( ///
        croplostdummy             "Crop loss --- 1-7 months" ///
        croplostdummyXassets_w1   "Crop loss \X initial assets" ///
        ln_croplostXassets_w1     "Log crop loss \X initial assets" ///
        ln_croplostXln_assets_w1  "Log crop loss \X log initial assets" ///
    )

file open table using `tables'/appendix_hours.tex, write append
file write table "\addlinespace" _n 
file close table

esttab `models' using `tables'/appendix_hours.tex, append ///
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
file write table "Robust standard errors clustered at household level in parentheses; " _n
file write table "* significant at 10\%; ** significant at 5\%; *** significant at 1\%." _n
file write table "Crop loss is a dummy for a per capita crop loss of `labCroploss'." _n
file write table "Log crop loss is log per capita crop loss plus 1." _n
file write table "Initial assets are assets per capita in round 1 of the survey and are measured in `labAsset'," _n
file write table "except that log of assets are taken off assets per capita in TZS." _n
file write table "\end{tablenotes}" _n
file write table "\end{threeparttable}" _n
file write table "\end{small}" _n
file write table "\end{center}" _n
file write table "\end{table}" _n
file close table

