// Main results with assets interactions
// anAppendixAssets.do

vers 13.1
clear
file close _all // makes working on code easier

//  short file paths - assuming work directory is "code"
loc data   "../data"
loc tables    "../tables"

use `data'/base

// data manipulation
do womenCommon 


//////////////////////////////////////////////////////////////////
// Fixed effect LPM Regressions with assets interactions        //
//////////////////////////////////////////////////////////////////

// base specification with interaction with wave 1 assets
eststo d_int_ca: xtreg contra_any croplostdummy croplostdummyXassets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_int_ct: xtreg contra_trad croplostdummy croplostdummyXassets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_int_cm: xtreg contra_mode croplostdummy croplostdummyXassets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_int_pr: xtreg pregnant croplostdummy croplostdummyXassets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_int_br: xtreg birth croplostdummy_lag croplostdummy_lagXassets_w1  pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace



/////////////////////////////////////////////////
// Tables                                      //
/////////////////////////////////////////////////

file open table using `tables'/appendix_asset_interaction.tex, write replace
file write table "\begin{table}[htbp]" _n
file write table "\begin{center}" _n
file write table "\begin{small}" _n
file write table "\begin{threeparttable}" _n
file write table "\caption{The Effects of Crop Loss on Contraceptives Use by Assets}" _n
file write table "\label{tab:assets}" _n
file write table "\begin{tabular}{@{} l D{.}{.}{2.6} D{.}{.}{2.6}  D{.}{.}{2.6} D{.}{.}{2.6} D{.}{.}{2.6}  @{}}" _n
file write table "\toprule" _n
file write table "                                                       & \mco{}              &\mco{}               &\multicolumn{3}{c}{Contraceptive Use}\\ \cmidrule(lr){4-6}" _n
file write table "                                                       & \mco{Pregnant}      &\mco{Birth}          &\mco{Any}            &\mco{Traditional}    & \mco{Modern}        \\ \midrule" _n
file close table

esttab d_int_pr d_int_br d_int_ca d_int_ct d_int_cm using `tables'/appendix_asset_interaction.tex, append ///
    fragment ///
	nogap nolines varwidth(55) label ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( _cons *pass* ) ///
    varlabels( ///
        croplostdummy               "Crop loss --- 1-7 months" ///
        croplostdummy_lag           "Crop loss --- 7-14 months" ///
        croplostdummyXassets_w1     "Crop loss \X initial assets" ///
        croplostdummy_lagXassets_w1 "Crop loss \X initial assets" ///
    )    


file open table using `tables'/appendix_asset_interaction.tex, write append
file write table "\addlinespace" _n 
file close table

esttab d_int_pr d_int_br d_int_ca d_int_ct d_int_cm using `tables'/appendix_asset_interaction.tex, append ///
    indicate("Wave dummies = pass2 pass3 pass4" , labels("\mco{Yes}" "\mco{No}")) ///
    s(fixed, label("Woman fixed effects")) ///
    fragment ///
	nogap nolines varwidth(55) label ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( _cons *croplost*)

// Observations / number of women
file open table using `tables'/appendix_asset_interaction.tex, write append
file write table "Observations" _col(56)
foreach res in d_int_pr d_int_br d_int_ca d_int_ct d_int_cm  {
    est restore `res'
    file write table "&    \mco{`e(N)'}        "
}
file write table "\\ " _n
file write table "Number of women" _col(56)
foreach res in d_int_pr d_int_br d_int_ca d_int_ct d_int_cm {
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
file write table "Initial assets are assets per capita in round 1 of the survey and are measured in 10,000 TZS." _n
file write table "\end{tablenotes}" _n
file write table "\end{threeparttable}" _n
file write table "\end{small}" _n
file write table "\end{center}" _n
file write table "\end{table}" _n
file close table

