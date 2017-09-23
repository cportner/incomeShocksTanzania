// Results when excluding abstinence 
// anExcludeAbstinence.do

vers 13.1
clear
file close _all // makes working on code easier

//  short file paths - assuming work directory is "code"
loc data   "../data"
loc tables    "../tables"

use `data'/base

// data manipulation
include womenCommon 

////////////////////////////////////////////////////
// Does the effects come mainly from abstinence?  //
////////////////////////////////////////////////////

// All contraceptives with the exception of abstinence
// If you use other contraceptives than abstinence then you are still
// considered to be using contraceptives
gen tradExcludeAbs  = (method1 == 2 | method1 == 3) | (method2 == 2 | method2 == 3)
gen abstinence_only = (method1 == 1 & method2 == .) | (method2 == 1 & method1 == .)
gen excludeAbs      = contra_any - abstinence_only

eststo exclude1: xtreg excludeAbs croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo exclude2: xtreg excludeAbs croplostdummy croplostdummyXassets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo exclude3: xtreg tradExcludeAbs croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo exclude4: xtreg tradExcludeAbs croplostdummy croplostdummyXassets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo exclude5: xtreg abstinence croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo exclude6: xtreg abstinence croplostdummy croplostdummyXassets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace


/////////////////////////////////////////////////
// Tables                                      //
/////////////////////////////////////////////////

file open table using `tables'/appendix_exclude_abstinence.tex, write replace
file write table "\begin{table}[htbp]" _n
file write table "\begin{center}" _n
file write table "\begin{small}" _n
file write table "\begin{threeparttable}" _n
file write table "\caption{Crop loss and Abstinence as Contraceptives}" _n
file write table "\label{tab:excludeAbs}" _n
file write table "\begin{tabular}{@{} l D{.}{.}{2.5} D{.}{.}{2.5}  D{.}{.}{2.5} D{.}{.}{2.5} D{.}{.}{2.5} D{.}{.}{2.5}   @{}}" _n
file write table "\toprule" _n
file write table "                                                       & \multicolumn{4}{c}{Contraceptive Use}\\ \cmidrule(lr){2-5}" _n
file write table "                                                       & \mct{Any, except }                 & \mct{Rhythm and}               & \mct{Abstinence}                     \\ " _n
file write table "                                                       & \mct{abstinence only}              & \mct{withdrawal\tnote{a}}      & \mct{only}                           \\ \midrule" _n
file close table

esttab exclude*  using `tables'/appendix_exclude_abstinence.tex, append ///
    fragment ///
	nogap nolines varwidth(55)  ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( _cons *pass* ) ///
    varlabels( ///
        croplostdummy           "Crop loss --- 1-7 months" ///
        croplostdummyXassets_w1 "Crop loss \X initial assets" ///
    )

file open table using `tables'/appendix_exclude_abstinence.tex, write append
file write table "\addlinespace" _n 
file close table

esttab exclude* using `tables'/appendix_exclude_abstinence.tex, append ///
    indicate("Wave dummies = pass2 pass3 pass4" , labels("\mco{Yes}" "\mco{No}")) ///
    s(fixed, label("Woman fixed effects")) ///
    fragment ///
	nogap nolines varwidth(55)  ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( _cons *croplost*)

// Observations / number of women
file open table using `tables'/appendix_exclude_abstinence.tex, write append
file write table "Observations" _col(56)
foreach res in exclude1 exclude2 exclude3 exclude4 exclude5 exclude6  {
    est restore `res'
    file write table "&    \mco{`e(N)'}        "
}
file write table "\\ " _n
file write table "Number of women" _col(56)
foreach res in exclude1 exclude2 exclude3 exclude4 exclude5 exclude6 {
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
file write table "Crop loss is a dummy for a per capita crop loss of `labCroploss'." _n
file write table "Initial assets are assets per capita in round 1 of the survey and are measured in `labAsset'." _n
file write table "\item[a] Some women who used rhythm or withdrawal also used abstinence or modern contraceptives." _n
file write table "\end{tablenotes}" _n
file write table "\end{threeparttable}" _n
file write table "\end{small}" _n
file write table "\end{center}" _n
file write table "\end{table}" _n
file close table

