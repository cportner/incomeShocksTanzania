// Main results
// anContraceptiveEffectiveness.do
// Finding the effect traditional and modern contraceptive use 7 months ago 
// on current pregnancy status
vers 13.1
clear
file close _all // makes working on code easier

//  short file paths - assuming work directory is "code"
loc data   "../data"
loc tables    "../tables"

use `data'/base

// data manipulation
include womenCommon 

// generate lagged contraceptive use
bysort id_person (passage): gen lag_contra_any    = contra_any[_n-1]
bysort id_person (passage): gen lag_contra_trad   = contra_trad[_n-1]
bysort id_person (passage): gen lag_contra_modern = contra_modern[_n-1]
bysort id_person (passage): gen numbirth2=numbirth[_n-1]

gen shockAny          = croplostdummy_lag * lag_contra_any
gen shockTraditional  = croplostdummy_lag * lag_contra_trad
gen shockModern       = croplostdummy_lag * lag_contra_modern

label variable shockAny         "Crop loss (7-14 months)  \X Any Contraceptive (7 months)"
label variable shockTraditional "Crop loss (7-14 months)  \X Traditional Contraceptive (7 months)"
label variable shockModern      "Crop loss (7-14 months)  \X Modern Contraceptive (7 months)"

////////////////////////////////////////////////////
// Effects of contraceptive use on pregnancy 	  //
////////////////////////////////////////////////////

loc xvar "pass3 pass4 "

// Any contraceptive use
eststo all: xtreg pregnant lag_contra_any shockAny croplostdummy_lag `xvar', fe cluster(id_hh)

// Traditional contraceptive use
eststo trad: xtreg pregnant lag_contra_trad shockTraditional croplostdummy_lag `xvar', fe cluster(id_hh)

// Modern contraceptive use
eststo mod: xtreg pregnant lag_contra_modern shockModern croplostdummy_lag `xvar', fe cluster(id_hh)


/////////////////////////////////////////////////
// Tables                                      //
/////////////////////////////////////////////////

file open table using `tables'/main_effectiveness.tex, write replace
file write table "\begin{table}[htbp]" _n
file write table "\begin{center}" _n
file write table "\begin{threeparttable}" _n
file write table "\caption{Contraceptive Use and Pregnancy}" _n
file write table "\label{tab:effectiveness}" _n
file write table "\begin{tabular}{@{} l  D{.}{.}{2.6} D{.}{.}{2.6} D{.}{.}{2.6}  @{}}" _n
file write table "\toprule" _n
file write table "                                                       & \multicolumn{3}{c}{Currently Pregnant} \\ \cmidrule(lr){2-4}" _n
file write table "                                                       &\mco{Any}            & \mco{Traditional}   & \mco{Modern}        \\ \midrule" _n
file close table

esttab all trad mod using `tables'/main_effectiveness.tex, append ///
    fragment ///
	nogap nolines varwidth(55) label ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop(_cons  *pass*) ///
	rename( ///
	    lag_contra_trad   lag_contra_any ///
	    lag_contra_modern lag_contra_any ///
	    shockTraditional  shockAny ///
	    shockModern       shockAny ///
	    ) ///
	varlabels( ///
	    lag_contra_any  "Contraceptives (7 months)" ///
	    shockAny        "Crop loss (7-14 months) \X Any Contraceptive (7 months)" ///
	    )
	    
file open table using `tables'/main_effectiveness.tex, write append
file write table "\addlinespace " _n
file write table "Wave dummies                                           &    \mco{Yes}        &    \mco{Yes}        &    \mco{Yes}        \\" _n
file write table "Woman fixed effects                                    &    \mco{Yes}        &    \mco{Yes}        &    \mco{Yes}        \\" _n
file write table "Observations" _col(56)
foreach res in all trad mod  {
    est restore `res'
    file write table "&    \mco{`e(N)'}        "
}
file write table "\\ " _n
file write table "Number of women" _col(56)
foreach res in all trad mod {
    est restore `res'
    loc numWomen = `e(N_g)' 
    file write table "&    \mco{`numWomen'}        "
}
file write table "\\ " _n
file write table "\addlinespace " _n
file write table "\bottomrule" _n
file write table "\end{tabular}" _n
// Table notes
file write table "\begin{tablenotes} \footnotesize" _n
file write table "\item \hspace*{-0.5em} \textbf{Note.}" _n
file write table "Robust standard errors clustered at household level in parentheses; " _n
file write table "* significant at 10\%; ** significant at 5\%; *** significant at 1\%." _n
file write table "\end{tablenotes}" _n
file write table "\end{threeparttable}" _n
file write table "\end{center}" _n
file write table "\end{table}" _n
file close table
