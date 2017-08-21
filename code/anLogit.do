// Main results with logit
// anLogit.do

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

// base specification without wave 1 asset interaction
eststo logit_ca_1: xtlogit contra_any croplostdummy  pass2 pass3 pass4 , fe 
estadd local fixed "\mco{Yes}" , replace
eststo logit_ct_1: xtlogit contra_trad croplostdummy  pass2 pass3 pass4 , fe 
estadd local fixed "\mco{Yes}" , replace
eststo logit_cm_1: xtlogit contra_mode croplostdummy  pass2 pass3 pass4 , fe 
estadd local fixed "\mco{Yes}" , replace
eststo logit_pr_1: xtlogit pregnant croplostdummy  pass2 pass3 pass4 , fe 
estadd local fixed "\mco{Yes}" , replace
eststo logit_br_1: xtlogit birth croplostdummy_lag  pass3 pass4 , fe 
estadd local fixed "\mco{Yes}" , replace

// base specification with interaction with wave 1 assets
eststo logit_int_ca: xtlogit contra_any croplostdummy croplostdummyXassets_w1 pass2 pass3 pass4 , fe 
eststo logit_int_ct: xtlogit contra_trad croplostdummy croplostdummyXassets_w1 pass2 pass3 pass4 , fe 
eststo logit_int_cm: xtlogit contra_mode croplostdummy croplostdummyXassets_w1 pass2 pass3 pass4 , fe 
eststo logit_int_pr: xtlogit pregnant croplostdummy croplostdummyXassets_w1 pass2 pass3 pass4 , fe 
eststo logit_int_br: xtlogit birth croplostdummy_lag croplostdummy_lagXassets_w1  pass3 pass4 , fe 


/////////////////////////////////////////////////
// Tables                                      //
/////////////////////////////////////////////////

file open table using `tables'/appendix_logit.tex, write replace
file write table "\begin{table}[htbp]" _n
file write table "\begin{center}" _n
file write table "\begin{small}" _n
file write table "\begin{threeparttable}" _n
file write table "\caption{The Effects of Crop Loss -- Logit Fixed Effects Estimates}" _n
file write table "\label{tab:logit}" _n
file write table "\begin{tabular}{@{} l D{.}{.}{2.6} D{.}{.}{2.6}  D{.}{.}{2.6} D{.}{.}{2.6} D{.}{.}{2.6}  @{}}" _n
file write table "\toprule" _n
file write table "                                                       & \mco{}              &\mco{}               &\multicolumn{3}{c}{Contraceptive Use}\\ \cmidrule(lr){4-6}" _n
file write table "                                                       & \mco{Pregnant}      &\mco{Birth}          &\mco{Any}            &\mco{Traditional}    & \mco{Modern}        \\ \midrule" _n
file write table " & \multicolumn{5}{c}{Without interaction with assets} \\" _n
file close table

esttab logit_pr_1 logit_br_1 logit_ca_1 logit_ct_1 logit_cm_1 using `tables'/appendix_logit.tex, append ///
    fragment ///
	nogap nolines varwidth(55) label ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( *pass* ) ///
    varlabels( ///
        croplostdummy     "Crop loss --- 1-7 months" ///
        croplostdummy_lag "Crop loss --- 7-14 months" ///
    )
 
file open table using `tables'/appendix_logit.tex, write append
file write table "\addlinespace" _n 
file write table " & \multicolumn{5}{c}{With interaction with assets} \\" _n
file close table

esttab logit_int_pr logit_int_br logit_int_ca logit_int_ct logit_int_cm using `tables'/appendix_logit.tex, append ///
    fragment ///
	nogap nolines varwidth(55) label ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( *pass* ) ///
    varlabels( ///
        croplostdummy     "Crop loss --- 1-7 months" ///
        croplostdummy_lag "Crop loss --- 7-14 months" ///
        croplostdummyXassets_w1     "Crop loss \X initial assets" ///
        croplostdummy_lagXassets_w1 "Crop loss \X initial assets" ///
    )    

file open table using `tables'/appendix_logit.tex, write append
file write table "\addlinespace" _n 
file close table

esttab logit_pr_1 logit_br_1 logit_ca_1 logit_ct_1 logit_cm_1 using `tables'/appendix_logit.tex, append ///
    indicate("Wave dummies = pass2 pass3 pass4" , labels("\mco{Yes}" "\mco{No}")) ///
    s(fixed, label("Woman fixed effects")) ///
    fragment ///
	nogap nolines varwidth(55) label ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( croplost*)

// Observations / number of women
file open table using `tables'/appendix_logit.tex, write append
file write table "Observations" _col(56)
foreach res in logit_pr_1 logit_br_1 logit_ca_1 logit_ct_1 logit_cm_1  {
    est restore `res'
    file write table "&    \mco{`e(N)'}        "
}
file write table "\\ " _n
file write table "Number of women" _col(56)
foreach res in logit_pr_1 logit_br_1 logit_ca_1 logit_ct_1 logit_cm_1 {
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
file write table "All models are conditional logit models." _n
file write table "Robust standard errors clustered at household level in parentheses; " _n
file write table "* significant at 10\%; ** significant at 5\%; *** significant at 1\%." _n
file write table "Crop loss is a dummy for a per capita crop loss of 200 TZS or above." _n
file write table "Assets are per capita and measured in 10,000 TZS." _n
file write table "\end{tablenotes}" _n
file write table "\end{threeparttable}" _n
file write table "\end{small}" _n
file write table "\end{center}" _n
file write table "\end{table}" _n
file close table

