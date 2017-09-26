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


// Women who rely only on abstinence for response to R1
gen abstinence_only = (method1 == 1 & method2 == .) | (method2 == 1 & method1 == .)
gen randw_only      = (method1 == 2 & (method2 == 3 | method2 == .)) ///
                    | (method1 == 3 & (method2 == 2 | method2 == .)) ///
                    | (method1 == . & (method2 == 2 | method2 == 3))
gen contra_exclude_abstinence_any     = contra_any - abstinence_only
gen contra_exclude_abstinence_trad    = contra_trad - abstinence_only
bysort id_person (passage): egen any_abstinence_only = max(abstinence_only)


// generate lagged contraceptive use
bysort id_person (passage): gen lag_contra_any    = contra_any[_n-1]
bysort id_person (passage): gen lag_contra_trad   = contra_trad[_n-1]
bysort id_person (passage): gen lag_contra_modern = contra_modern[_n-1]
bysort id_person (passage): gen lag2_contra_any    = contra_any[_n-2]
bysort id_person (passage): gen lag2_contra_trad   = contra_trad[_n-2]
bysort id_person (passage): gen lag2_contra_modern = contra_modern[_n-2]
bysort id_person (passage): gen lag_abstinence_only = abstinence_only[_n-1] 
bysort id_person (passage): gen lag_randw_only    = randw_only[_n-1]
bysort id_person (passage): gen lag_exc_ab_any    = contra_exclude_abstinence_any[_n-1]
bysort id_person (passage): gen lag_exc_ab_trad   = contra_exclude_abstinence_trad[_n-1]
bysort id_person (passage): gen numbirth2=numbirth[_n-1]

gen shockAny             = croplostdummy_lag * lag_contra_any
gen shockTraditional     = croplostdummy_lag * lag_contra_trad
gen shockModern          = croplostdummy_lag * lag_contra_modern
gen shock2Any            = croplostdummy_lag2 * lag2_contra_any
gen shock2Traditional    = croplostdummy_lag2 * lag2_contra_trad
gen shock2Modern         = croplostdummy_lag2 * lag2_contra_modern
gen shockAbstinence_only = croplostdummy_lag * lag_abstinence_only
gen shockrandw_only      = croplostdummy_lag * lag_randw_only
gen shockExAbAny         = croplostdummy_lag * lag_exc_ab_any
gen shockExAbTrad        = croplostdummy_lag * lag_exc_ab_trad

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

// Combined show little difference in estimates
xtreg pregnant lag_contra_trad shockTraditional lag_contra_modern shockModern  croplostdummy_lag `xvar', fe cluster(id_hh)


// Alternative specifications
eststo abs_only: xtreg pregnant lag_abstinence_only shockAbstinence_only croplostdummy_lag `xvar' , fe cluster(id_hh)
eststo abs_any : xtreg pregnant lag_abstinence_only shockAbstinence_only lag_exc_ab_any  shockExAbAny  croplostdummy_lag `xvar' , fe cluster(id_hh)
eststo abs_all : xtreg pregnant lag_abstinence_only shockAbstinence_only lag_exc_ab_trad shockExAbTrad lag_contra_modern shockModern  croplostdummy_lag `xvar' , fe cluster(id_hh)

xtreg pregnant lag_randw_only shockrandw_only croplostdummy_lag `xvar' , fe cluster(id_hh)

// xtreg pregnant lag_exc_ab_any  shockExAbAny croplostdummy_lag `xvar' , fe cluster(id_hh)
// xtreg pregnant lag_exc_ab_any  shockExAbAny croplostdummy_lag `xvar' if !any_abstinence_only, fe cluster(id_hh)
// 
// xtreg pregnant lag_exc_ab_trad shockExAbTrad croplostdummy_lag `xvar' , fe cluster(id_hh)
// xtreg pregnant lag_exc_ab_trad shockExAbTrad croplostdummy_lag `xvar' if !any_abstinence_only, fe cluster(id_hh)



/////////////////////////////////////////////////
// Tables                                      //
/////////////////////////////////////////////////

loc models "all trad mod"

file open table using `tables'/main_effectiveness.tex, write replace
file write table "\begin{table}[htbp]" _n
file write table "\begin{center}" _n
file write table "\begin{threeparttable}" _n
file write table "\caption{Lagged Contraceptive Use and Current Pregnancy}" _n
file write table "\label{tab:effectiveness}" _n
file write table "\begin{tabular}{@{} l  D{.}{.}{2.6} D{.}{.}{2.6} D{.}{.}{2.6}  @{}}" _n
file write table "\toprule" _n
file write table "                                                       & \multicolumn{3}{c}{Contraception Method(s)} \\ \cmidrule(lr){2-4}" _n
file write table "                                                       &\mco{Any}            & \mco{Traditional}   & \mco{Modern}        \\ \midrule" _n
file close table

esttab `models' using `tables'/main_effectiveness.tex, append ///
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
	    shockAny        "Crop loss (7-14 months) \X Contraceptives (7 months)" ///
	    )
	    
file open table using `tables'/main_effectiveness.tex, write append
file write table "\addlinespace " _n
file write table "Wave dummies                                           &    \mco{Yes}        &    \mco{Yes}        &    \mco{Yes}        \\" _n
file write table "Woman fixed effects                                    &    \mco{Yes}        &    \mco{Yes}        &    \mco{Yes}        \\" _n
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



// Alternative tables

// loc models "abs_only abs_any abs_all"

loc models "abs_only  abs_all"


file open table using `tables'/appendix_abstinence.tex, write replace
file write table "\begin{table}[htbp]" _n
file write table "\begin{center}" _n
file write table "\begin{threeparttable}" _n
file write table "\caption{Lagged Contraceptive Use and Current Pregnancy by Method}" _n
file write table "\label{tab:abstinence}" _n
// file write table "\begin{tabular}{@{} l  D{.}{.}{2.6} D{.}{.}{2.6} D{.}{.}{2.6}  @{}}" _n
file write table "\begin{tabular}{@{} l  D{.}{.}{2.6} D{.}{.}{2.6}  @{}}" _n
file write table "\toprule" _n
// file write table "                                                       &\mco{Model I}            & \mco{Model II}   & \mco{Model III}        \\ \midrule" _n
file write table "                                                       &\mco{Model I}            & \mco{Model II}           \\ \midrule" _n
file close table

esttab `models' using `tables'/appendix_abstinence.tex, append ///
    fragment ///
	nogap nolines varwidth(55) label ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop(_cons  *pass*) ///
	varlabels( ///
	    lag_abstinence_only     "Abstinence only (7 months)\tnote{a}" ///
	    shockAbstinence_only    "Crop loss (7-14 months) \X Abstinence only (7 months)" ///
	    lag_exc_ab_any          "Non-abstinence method (7 months)" ///
	    shockExAbAny            "Crop loss (7-14 months) \X Non-abstinence (7 months)" ///
	    lag_exc_ab_trad         "Other traditional method(s) (7-14 months)\tnote{b}" ///
	    shockExAbTrad           "Crop loss (7-14 months) \X Other traditional (7 months)" ///
	    lag_contra_modern       "Modern contraceptive (7-14 months)\tnote{c}" ///
	    shockModern             "Crop loss (7-14 months) \X Modern (7 months)" ///
	) ///
	order( lag_abstinence_only shockAbsti* lag_exc_ab_trad ///
	    shockExAbTrad lag_contra_modern shockModern croplostdummy_lag ///
	)

// 	order( lag_abstinence_only shockAbsti* lag_exc_ab_any shockExAbAny lag_exc_ab_trad ///
// 	    shockExAbTrad lag_contra_modern shockModern croplostdummy_lag ///
// 	)

	    
file open table using `tables'/appendix_abstinence.tex, write append
file write table "\addlinespace " _n
// file write table "Wave dummies                                           &    \mco{Yes}        &    \mco{Yes}        &    \mco{Yes}        \\" _n
// file write table "Woman fixed effects                                    &    \mco{Yes}        &    \mco{Yes}        &    \mco{Yes}        \\" _n
file write table "Wave dummies                                           &    \mco{Yes}        &    \mco{Yes}        \\" _n
file write table "Woman fixed effects                                    &    \mco{Yes}        &    \mco{Yes}        \\" _n
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
file write table "\addlinespace " _n
file write table "\bottomrule" _n
file write table "\end{tabular}" _n
// Table notes
file write table "\begin{tablenotes} \footnotesize" _n
file write table "\item \hspace*{-0.5em} \textbf{Note.}" _n
file write table "Robust standard errors clustered at household level in parentheses; " _n
file write table "* significant at 10\%; ** significant at 5\%; *** significant at 1\%." _n
sum pregnant if lag_abstinence_only == 1
file write table "\item[a] Across waves 1 through 3, `r(N)' women report abstinence only."
sum pregnant if lag_exc_ab_trad == 1 & lag_contra_modern == 1
loc combine = `r(N)'
file write table "\item[b] Includes women who use abstinence in combination with other methods (16 women)" _n
file write table "or rhythm/withdrawal alone or in combination with other methods (23 women)." _n
file write table "These 39 women include `combine' women who report use of modern methods in addition to traditional." _n
sum lag_contra_modern if lag_contra_modern == 1
file write table "\item[c] Of the `r(N)' women, `combine' also report abstinence or other traditional methods." _n
file write table "\end{tablenotes}" _n
file write table "\end{threeparttable}" _n
file write table "\end{center}" _n
file write table "\end{table}" _n
file close table


