// Main results with different cut-offs for crop loss
// anCut_offs.do

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
// Fixed effect LPM Regressions with varying crop loss cut-offs //
//////////////////////////////////////////////////////////////////


dis "`labAmount'"

// need to remove TZS and comma to use the number
if regexm("`labAmount'", "([0-9]+),([0-9]+).*") loc divider = regexs(1) + regexs(2)

loc cutoffs "0 100 200 300 400 1000 2000 5000 10000"

foreach cut of numlist `cutoffs' {
    gen newcut_`cut' = croplostamount_pc > (`cut'/`divider')
    bysort id_person (passage) : gen newcut_lag_`cut' = newcut_`cut'[_n-1]
    eststo cut`cut'_c_a : xtreg contra_any newcut_`cut'  pass2 pass3 pass4 , fe cluster(id_hh)
    estadd local fixed "\mco{Yes}" , replace
    eststo cut`cut'_c_tr: xtreg contra_trad newcut_`cut'  pass2 pass3 pass4 , fe cluster(id_hh)
    estadd local fixed "\mco{Yes}" , replace
    eststo cut`cut'_c_mo: xtreg contra_mode newcut_`cut'  pass2 pass3 pass4 , fe cluster(id_hh)
    estadd local fixed "\mco{Yes}" , replace
    eststo cut`cut'_pr  : xtreg pregnant newcut_`cut'  pass2 pass3 pass4 , fe cluster(id_hh)
    estadd local fixed "\mco{Yes}" , replace
    eststo cut`cut'_br  : xtreg birth newcut_lag_`cut'  pass3 pass4 , fe cluster(id_hh)
    estadd local fixed "\mco{Yes}" , replace
    
    sum newcut_`cut' 
    loc mean_`cut' = round(`r(mean)' * 100, 0.1)
}


/////////////////////////////////////////////////
// Tables                                      //
/////////////////////////////////////////////////

file open table using `tables'/appendix_cut_offs.tex, write replace
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
file close table

foreach cut of numlist `cutoffs' {

    file open table using `tables'/appendix_cut_offs.tex, write append
    file write table " & \multicolumn{5}{c}{Cut-off: "
    file write table %7.0fc (`cut')
    file write table " TZS; `mean_`cut''\% of observations affected} \\" _n
    file close table
    
    esttab cut`cut'_pr cut`cut'_br cut`cut'_c_a cut`cut'_c_tr cut`cut'_c_mo using `tables'/appendix_cut_offs.tex, append ///
        fragment ///
        nogap nolines varwidth(55) label ///
        collabels(none) mlabels(none) eqlabels(none) ///
        nomtitles nonumber nodepvars noobs ///
        se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
        drop( _cons *pass* ) ///
        varlabels( ///
            newcut_`cut'     "Crop loss --- 1-7 months"  ///
            newcut_lag_`cut' "Crop loss --- 7-14 months" ///
        )

    file open table using `tables'/appendix_cut_offs.tex, write append
    file write table "\addlinespace" _n
    file close table
    
} 

loc cut = 200

esttab cut`cut'_pr cut`cut'_br cut`cut'_c_a cut`cut'_c_tr cut`cut'_c_mo using `tables'/appendix_cut_offs.tex, append ///
    indicate("Wave dummies = pass2 pass3 pass4" , labels("\mco{Yes}" "\mco{No}")) ///
    s(fixed, label("Woman fixed effects")) ///
    fragment ///
	nogap nolines varwidth(55) label ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( _cons *cut*)

// Observations / number of women
file open table using `tables'/appendix_cut_offs.tex, write append
file write table "Observations" _col(56)
foreach res in cut`cut'_pr cut`cut'_br cut`cut'_c_a cut`cut'_c_tr cut`cut'_c_mo  {
    est restore `res'
    file write table "&    \mco{`e(N)'}        "
}
file write table "\\ " _n
file write table "Number of women" _col(56)
foreach res in cut`cut'_pr cut`cut'_br cut`cut'_c_a cut`cut'_c_tr cut`cut'_c_mo {
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
// file write table "Crop loss is log per capita crop loss plus 1." _n
// file write table "Initial assets are assets per capita in round 1 of the survey and are measured in `labAsset'," _n
// file write table "except that log of assets are taken off assets per capita in TZS." _n
file write table "\end{tablenotes}" _n
file write table "\end{threeparttable}" _n
file write table "\end{small}" _n
file write table "\end{center}" _n
file write table "\end{table}" _n
file close table

