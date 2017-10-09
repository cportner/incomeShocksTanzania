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
include womenCommon 


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

// Log crop loss interacted with log wave 1 assets
eststo lnfe_int_ca: xtreg contra_any ln_croplostamount_pc ln_croplostXln_assets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
eststo lnfe_int_ct: xtreg contra_trad ln_croplostamount_pc ln_croplostXln_assets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
eststo lnfe_int_cm: xtreg contra_mode ln_croplostamount_pc ln_croplostXln_assets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
eststo lnfe_int_pr: xtreg pregnant ln_croplostamount_pc ln_croplostXln_assets_w1  pass3 pass4 , fe cluster(id_hh)
eststo lnfe_int_br: xtreg birth ln_croplostamount_pc_lag ln_croplost_lagXln_assets_w1 pass2 pass3 pass4 , fe cluster(id_hh)


// Exclude wave 1 shocks because assets are measured at wave 1
eststo mw1_int_ca: xtreg contra_any croplostdummy croplostdummyXassets_w1  pass3 pass4 if wave != 1 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo mw1_int_ct: xtreg contra_trad croplostdummy croplostdummyXassets_w1  pass3 pass4 if wave != 1 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo mw1_int_cm: xtreg contra_mode croplostdummy croplostdummyXassets_w1  pass3 pass4 if wave != 1 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo mw1_int_pr: xtreg pregnant croplostdummy croplostdummyXassets_w1  pass3 pass4 if wave != 1 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo mw1_int_br: xtreg birth croplostdummy_lag croplostdummy_lagXassets_w1 pass3 pass4 if wave != 2 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace


// base specification with interaction with wave 1 assets
eststo mw1_ln_int_ca: xtreg contra_any ln_croplostamount_pc ln_croplostXln_assets_w1 pass3 pass4 if wave != 1 , fe cluster(id_hh)
eststo mw1_ln_int_ct: xtreg contra_trad ln_croplostamount_pc ln_croplostXln_assets_w1 pass3 pass4 if wave != 1 , fe cluster(id_hh)
eststo mw1_ln_int_cm: xtreg contra_mode ln_croplostamount_pc ln_croplostXln_assets_w1 pass3 pass4 if wave != 1 , fe cluster(id_hh)
eststo mw1_ln_int_pr: xtreg pregnant ln_croplostamount_pc ln_croplostXln_assets_w1  pass3 pass4 if wave != 1 , fe cluster(id_hh)
eststo mw1_ln_int_br: xtreg birth ln_croplostamount_pc_lag ln_croplost_lagXln_assets_w1 pass3 pass4 if wave != 1 , fe cluster(id_hh)

/////////////////////////////////////////////////
// Tables                                      //
/////////////////////////////////////////////////

file open table using `tables'/appendix_asset_interaction.tex, write replace
file write table "\begin{table}[htbp]" _n
file write table "\begin{center}" _n
file write table "\begin{footnotesize}" _n
file write table "\begin{threeparttable}" _n
file write table "\caption{The Effects of Crop Loss on Contraceptives Use by Assets}" _n
file write table "\label{tab:assets}" _n
file write table "\begin{tabular}{@{} l D{.}{.}{2.6} D{.}{.}{2.6}  D{.}{.}{2.6} D{.}{.}{2.6} D{.}{.}{2.6}  @{}}" _n
file write table "\toprule" _n
file write table "                                                       & \mco{}              &\mco{}               &\multicolumn{3}{c}{Contraceptive Use}\\ \cmidrule(lr){4-6}" _n
file write table "                                                       & \mco{Pregnant}      &\mco{Birth}          &\mco{Any}            &\mco{Traditional}    & \mco{Modern}        \\ \midrule" _n
file write table "                                                       & \multicolumn{5}{c}{All waves included} \\" _n
file close table

loc models "d_int_pr d_int_br d_int_ca d_int_ct d_int_cm"

esttab `models' using `tables'/appendix_asset_interaction.tex, append ///
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


esttab lnfe_int_pr lnfe_int_br lnfe_int_ca lnfe_int_ct lnfe_int_cm using `tables'/appendix_asset_interaction.tex, append ///
    fragment ///
	nogap nolines varwidth(55) label ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( _cons *pass* ) ///
    varlabels( ///
        croplostdummy               "Crop loss --- 1-7 months" ///
        croplostdummy_lag           "Crop loss --- 7-14 months" ///
        ln_croplostXln_assets_w1     "Log crop loss \X log initial assets" ///
        ln_croplost_lagXln_assets_w1 "Log crop loss \X log initial assets" ///
    )    


file open table using `tables'/appendix_asset_interaction.tex, write append
file write table "\addlinespace" _n 
file close table


esttab `models' using `tables'/appendix_asset_interaction.tex, append ///
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
file write table "\addlinespace" _n
file write table "                                                       & \multicolumn{5}{c}{Wave 1 shocks not included} \\" _n
file close table

loc models "mw1_int_pr mw1_int_br mw1_int_ca mw1_int_ct mw1_int_cm"

esttab `models' using `tables'/appendix_asset_interaction.tex, append ///
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


esttab mw1_ln_int_pr mw1_ln_int_br mw1_ln_int_ca mw1_ln_int_ct mw1_ln_int_cm using `tables'/appendix_asset_interaction.tex, append ///
    fragment ///
	nogap nolines varwidth(55) label ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( _cons *pass* ) ///
    varlabels( ///
        croplostdummy               "Crop loss --- 1-7 months" ///
        croplostdummy_lag           "Crop loss --- 7-14 months" ///
        ln_croplostXln_assets_w1     "Log crop loss \X log initial assets" ///
        ln_croplost_lagXln_assets_w1 "Log crop loss \X log initial assets" ///
    )    


file open table using `tables'/appendix_asset_interaction.tex, write append
file write table "\addlinespace" _n 
file close table


esttab `models' using `tables'/appendix_asset_interaction.tex, append ///
    indicate("Wave dummies =  pass3 pass4" , labels("\mco{Yes}" "\mco{No}")) ///
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
file write table "\begin{tablenotes} \scriptsize" _n
file write table "\item \hspace*{-0.5em} \textbf{Note.}" _n
file write table "All models are linear probability models." _n
file write table "Robust standard errors clustered at household level in parentheses; " _n
file write table "* significant at 10\%; ** significant at 5\%; *** significant at 1\%." _n
file write table "Crop loss is a dummy for a per capita crop loss of `labCroploss'." _n
file write table "Log crop loss is log per capita crop loss plus 1." _n
file write table "Initial assets are assets per capita in round 1 of the survey and are measured in `labAsset'," _n
file write table "except that log of assets are taken off assets per capita in TZS." _n
file write table "\end{tablenotes}" _n
file write table "\end{threeparttable}" _n
file write table "\end{footnotesize}" _n
file write table "\end{center}" _n
file write table "\end{table}" _n
file close table

