// Main results with log crop loss
// anLogCropLoss.do

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
// Fixed effect LPM Regressions with log continuous crop loss   //
//////////////////////////////////////////////////////////////////

// base specification without wave 1 asset interaction
eststo lnfe_c_a:  xtreg contra_any ln_croplostamount_pc  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo lnfe_c_tr: xtreg contra_trad ln_croplostamount_pc  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo lnfe_c_mo: xtreg contra_mode ln_croplostamount_pc  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo lnfe_pr:   xtreg pregnant ln_croplostamount_pc  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo lnfe_br:   xtreg birth ln_croplostamount_pc_lag  pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace

// base specification with interaction with wave 1 assets
eststo lnfe_int_c_a:  xtreg contra_any ln_croplostamount_pc ln_croplostXassets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
eststo lnfe_int_c_tr: xtreg contra_trad ln_croplostamount_pc ln_croplostXassets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
eststo lnfe_int_c_mo: xtreg contra_mode ln_croplostamount_pc ln_croplostXassets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
eststo lnfe_int_pr:   xtreg pregnant ln_croplostamount_pc ln_croplostXassets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
eststo lnfe_int_br:   xtreg birth ln_croplostamount_pc_lag ln_croplost_lagXassets_w1  pass3 pass4 , fe cluster(id_hh)

// base specification with interaction with log of wave 1 assets
eststo lnlnfe_int_c_a:  xtreg contra_any ln_croplostamount_pc ln_croplostXln_assets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
eststo lnlnfe_int_c_tr: xtreg contra_trad ln_croplostamount_pc ln_croplostXln_assets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
eststo lnlnfe_int_c_mo: xtreg contra_mode ln_croplostamount_pc ln_croplostXln_assets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
eststo lnlnfe_int_pr:   xtreg pregnant ln_croplostamount_pc ln_croplostXln_assets_w1 pass2 pass3 pass4 , fe cluster(id_hh)
eststo lnlnfe_int_br:   xtreg birth ln_croplostamount_pc_lag ln_croplost_lagXln_assets_w1  pass3 pass4 , fe cluster(id_hh)




/////////////////////////////////////////////////
// Tables                                      //
/////////////////////////////////////////////////

file open table using `tables'/appendix_log_croploss.tex, write replace
file write table "\begin{table}[htbp]" _n
file write table "\begin{center}" _n
file write table "\begin{small}" _n
file write table "\begin{threeparttable}" _n
file write table "\caption{The Effects of Log Crop Loss}" _n
file write table "\label{tab:ln_croploss}" _n
file write table "\begin{tabular}{@{} l D{.}{.}{2.6} D{.}{.}{2.6}  D{.}{.}{2.6} D{.}{.}{2.6} D{.}{.}{2.6}  @{}}" _n
file write table "\toprule" _n
file write table "                                                       & \mco{}              &\mco{}               &\multicolumn{3}{c}{Contraceptive Use}\\ \cmidrule(lr){4-6}" _n
file write table "                                                       & \mco{Pregnant}      &\mco{Birth}          &\mco{Any}            &\mco{Traditional}    & \mco{Modern}        \\ \midrule" _n
file write table " & \multicolumn{5}{c}{Without interaction with assets} \\" _n
file close table

esttab lnfe_pr lnfe_br lnfe_c_a lnfe_c_tr lnfe_c_mo using `tables'/appendix_log_croploss.tex, append ///
    fragment ///
	nogap nolines varwidth(55) label ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( _cons *pass* ) 
 
file open table using `tables'/appendix_log_croploss.tex, write append
file write table "\addlinespace" _n 
file write table " & \multicolumn{5}{c}{With interaction with assets} \\" _n
file close table

esttab lnfe_int_pr lnfe_int_br lnfe_int_c_a lnfe_int_c_tr lnfe_int_c_mo using `tables'/appendix_log_croploss.tex, append ///
    fragment ///
	nogap nolines varwidth(55) label ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( _cons *pass* ) ///
    varlabels( ///
        ln_croplostXassets_w1     "Log crop loss \X initial assets" ///
        ln_croplost_lagXassets_w1 "Log crop loss \X initial assets" ///
    )    

file open table using `tables'/appendix_log_croploss.tex, write append
file write table "\addlinespace" _n 
file write table " & \multicolumn{5}{c}{With interaction with log assets} \\" _n
file close table

esttab lnlnfe_int_pr lnlnfe_int_br lnlnfe_int_c_a lnlnfe_int_c_tr lnlnfe_int_c_mo using `tables'/appendix_log_croploss.tex, append ///
    fragment ///
	nogap nolines varwidth(55) label ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( _cons *pass* ) ///
    varlabels( ///
        ln_croplostXln_assets_w1     "Log crop loss \X log initial assets" ///
        ln_croplost_lagXln_assets_w1 "Log crop loss \X log initial assets" ///
    )    

file open table using `tables'/appendix_log_croploss.tex, write append
file write table "\addlinespace" _n 
file close table

esttab lnfe_pr lnfe_br lnfe_c_a lnfe_c_tr lnfe_c_mo using `tables'/appendix_log_croploss.tex, append ///
    indicate("Wave dummies = pass2 pass3 pass4" , labels("\mco{Yes}" "\mco{No}")) ///
    s(fixed, label("Woman fixed effects")) ///
    fragment ///
	nogap nolines varwidth(55) label ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( _cons *croplost*)

// Observations / number of women
file open table using `tables'/appendix_log_croploss.tex, write append
file write table "Observations" _col(56)
foreach res in lnfe_pr lnfe_br lnfe_c_a lnfe_c_tr lnfe_c_mo  {
    est restore `res'
    file write table "&    \mco{`e(N)'}        "
}
file write table "\\ " _n
file write table "Number of women" _col(56)
foreach res in lnfe_pr lnfe_br lnfe_c_a lnfe_c_tr lnfe_c_mo {
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
file write table "Crop loss is log per capita crop loss plus 1." _n
file write table "Initial assets are assets per capita in round 1 of the survey and are measured in 10,000 TZS," _n
file write table "except that log of assets are taken off assets per capita in TZS." _n
file write table "\end{tablenotes}" _n
file write table "\end{threeparttable}" _n
file write table "\end{small}" _n
file write table "\end{center}" _n
file write table "\end{table}" _n
file close table

