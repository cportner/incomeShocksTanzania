// Include time trend and interaction with time trend
// anTimeTrend.do

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

loc xvar "c.assets_pc_wave1 i.educ017 i.agegroup"


// Woman fixed effects base specification without wave 1 asset interaction
eststo d_ca_0: xtreg contra_any croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_ca_1: xtreg contra_any croplostdummy c.wave#(`xvar') pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_ca_2: xtreg contra_any croplostdummy  i.pass2#(`xvar') i.pass3#(`xvar') i.pass4#(`xvar') , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace


eststo d_ct_0: xtreg contra_trad croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_ct_1: xtreg contra_trad croplostdummy c.wave#(`xvar')  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_ct_2: xtreg contra_trad croplostdummy  i.pass2#(`xvar') i.pass3#(`xvar') i.pass4#(`xvar') , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace

eststo d_cm_0: xtreg contra_mode croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_cm_1: xtreg contra_mode croplostdummy c.wave#(`xvar')  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_cm_2: xtreg contra_mode croplostdummy  i.pass2#(`xvar') i.pass3#(`xvar') i.pass4#(`xvar') , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace

eststo d_pr_0: xtreg pregnant croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_pr_1: xtreg pregnant croplostdummy c.wave#(`xvar')  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_pr_2: xtreg pregnant croplostdummy  i.pass2#(`xvar') i.pass3#(`xvar') i.pass4#(`xvar') , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace

eststo d_br_0: xtreg birth  croplostdummy_lag  pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_br_1: xtreg birth  croplostdummy_lag c.wave#(`xvar')  pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_br_2: xtreg birth  croplostdummy_lag  i.pass3#(`xvar') i.pass4#(`xvar') , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace



/////////////////////////////////////////////////
// Tables                                      //
/////////////////////////////////////////////////


// Pregnancy and birth table

file open table using `tables'/appendix_timetrend.tex, write replace
file write table "\begin{table}[htbp]" _n
file write table "\begin{center}" _n
file write table "\begin{threeparttable}" _n
file write table "\caption{Effects of Crop Loss With Time Trend}" _n
file write table "\label{tab:timetrend_birth}" _n
file write table "\begin{tabular}{@{} l D{.}{.}{1.5} D{.}{.}{1.5} D{.}{.}{1.5} @{}}" _n
file write table "\toprule" _n
file write table "                                                       & \mco{Original}      & \mco{Time Trend}     & \mco{Wave Dummies}   \\ " _n
file write table "                                                       & \mco{Model}         & \mco{Interacted}     & \mco{Interacted}     \\ " _n
file write table "\midrule" _n
file write table "                                                       & \multicolumn{3}{c}{Currently pregnant} \\  " _n
file close table

// Pregnancy

esttab d_pr_0 d_pr_1 d_pr_2 using `tables'/appendix_timetrend.tex, append ///
    fragment ///
	nogap nolines varwidth(55)  ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( *0.* pass* _cons *assets* *educ* *agegroup*) ///
    varlabels( ///
        croplostdummy     "Crop loss --- 1-7 months" ///
    )
    
file open table using `tables'/appendix_timetrend.tex, write append
file write table "\addlinespace" _n
// // Dummy / fixed effects indicators
// file write table "Wave dummies                                                 &  \mco{Yes}          &  \mco{Yes}          &  \mco{Yes}    \\" _n
// file write table "Time trend interacted with wave 1 characteristics\tnote{a}   &  \mco{No}           &  \mco{Yes}          &  \mco{No}     \\" _n
// file write table "Wave dummies interacted with wave 1 characteristics\tnote{b} &  \mco{No}           &  \mco{No}           &  \mco{Yes}    \\" _n
// file write table "Woman fixed effects                                          &    \mco{Yes}        &    \mco{Yes}        &    \mco{Yes}        \\" _n
// Observations / number of women
file write table "Observations" _col(56)
foreach res in d_pr_0 d_pr_1 d_pr_2  {
    est restore `res'
    file write table "&    \mco{`e(N)'}        "
}
file write table "\\ " _n
file write table "Number of women" _col(56)
foreach res in d_pr_0 d_pr_1 d_pr_2  {
    est restore `res'
    loc numWomen = `e(N_g)' 
    file write table "&    \mco{`numWomen'}        "
}
file write table "\\ " _n

// Births

file write table "\addlinespace" _n
file write table "                                                       & \multicolumn{3}{c}{Birth since last survey} \\ " _n
file close table

esttab d_br_0 d_br_1 d_br_2 using `tables'/appendix_timetrend.tex, append ///
    fragment ///
	nogap nolines varwidth(55)  ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( *0.* pass* _cons *assets* *educ* *agegroup*) ///
    varlabels( ///
        croplostdummy_lag  "Crop loss --- 7-14 months" ///
    )

file open table using `tables'/appendix_timetrend.tex, write append
file write table "\addlinespace" _n
// Dummy / fixed effects indicators
// file write table "Wave dummies                                                 &  \mco{Yes}          &  \mco{Yes}          &  \mco{Yes}    \\" _n
// file write table "Time trend interacted with wave 1 characteristics\tnote{a}   &  \mco{No}           &  \mco{Yes}          &  \mco{No}     \\" _n
// file write table "Wave dummies interacted with wave 1 characteristics\tnote{b} &  \mco{No}           &  \mco{No}           &  \mco{Yes}    \\" _n
// file write table "Woman fixed effects                                          &    \mco{Yes}        &    \mco{Yes}        &    \mco{Yes}        \\" _n
// Observations / number of women
file write table "Observations" _col(56)
foreach res in d_br_0 d_br_1 d_br_2  {
    est restore `res'
    file write table "&    \mco{`e(N)'}        "
}
file write table "\\ " _n
file write table "Number of women" _col(56)
foreach res in d_pr_0 d_pr_1 d_pr_2  {
    est restore `res'
    loc numWomen = `e(N_g)' 
    file write table "&    \mco{`numWomen'}        "
}
file write table "\\ " _n


// file write table "\bottomrule" _n
// file write table "\end{tabular}" _n
// file write table "\begin{tablenotes} \footnotesize" _n
// file write table "\item \hspace*{-0.5em} \textbf{Note.}" _n
// file write table "All models are linear probability models." _n
// file write table "Robust standard errors clustered at household level in parentheses; " _n
// file write table "* significant at 10\%; ** significant at 5\%; *** significant at 1\%." _n
// file write table "Crop loss is a dummy for a per capita crop loss of `labCroploss'." _n
// file write table "\item[a] Linear time trend interacted with assets per capita in wave 1, " _n
// file write table "dummies for education levels, and dummies for age groups." _n
// file write table "\item[b] Wave dummies interacted with assets per capita in wave 1, " _n
// file write table "dummies for education levels, and dummies for age groups." _n
// file write table "\end{tablenotes}" _n
// file write table "\end{threeparttable}" _n
// file write table "\end{center}" _n
// file write table "\end{table}" _n
// file close table
// 
//     
// 
// // Contraceptive use table
// 
// file open table using `tables'/appendix_timetrend.tex, write replace
// file write table "\begin{table}[htbp]" _n
// file write table "\begin{center}" _n
// file write table "\begin{threeparttable}" _n
// file write table "\caption{Effects of Crop Loss on Contraceptive Use Overall and By Type With Time Trend}" _n
// file write table "\label{tab:timetrend_contraceptive}" _n
// file write table "\begin{tabular}{@{} l D{.}{.}{2.6}  D{.}{.}{2.6} D{.}{.}{2.6}  @{}}" _n
// file write table "\toprule" _n
// file write table "                                                       &                     & \mco{Time Trend}     & \mco{Interaction with}   \\ " _n
// file write table "                                                       & \mco{Original}      & \mco{Interacted}     & \mco{Wave Dummies}    \\ " _n
// file write table "\midrule" _n
file write table "                                                       & \multicolumn{3}{c}{Any contraception}  \\ " _n

file close table

esttab d_ca_0 d_ca_1 d_ca_2 using `tables'/appendix_timetrend.tex, append ///
    fragment ///
	nogap nolines varwidth(55)  ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( *0.* pass* _cons *assets* *educ* *agegroup*) ///
    varlabels( ///
        croplostdummy     "Crop loss --- 1-7 months" ///
    )
    
file open table using `tables'/appendix_timetrend.tex, write append
file write table "\addlinespace" _n
// Dummy / fixed effects indicators
// file write table "Wave dummies                                                 &  \mco{Yes}          &  \mco{Yes}          &  \mco{Yes}    \\" _n
// file write table "Time trend interacted with wave 1 characteristics\tnote{a}   &  \mco{No}           &  \mco{Yes}          &  \mco{No}     \\" _n
// file write table "Wave dummies interacted with wave 1 characteristics\tnote{b} &  \mco{No}           &  \mco{No}           &  \mco{Yes}    \\" _n
// file write table "Woman fixed effects                                          &    \mco{Yes}        &    \mco{Yes}        &    \mco{Yes}        \\" _n
// Observations / number of women
file write table "Observations" _col(56)
foreach res in d_pr_0 d_pr_1 d_pr_2  {
    est restore `res'
    file write table "&    \mco{`e(N)'}        "
}
file write table "\\ " _n
file write table "Number of women" _col(56)
foreach res in d_pr_0 d_pr_1 d_pr_2  {
    est restore `res'
    loc numWomen = `e(N_g)' 
    file write table "&    \mco{`numWomen'}        "
}
file write table "\\ " _n
file write table "\addlinespace" _n
file write table _col(56) "&\multicolumn{3}{c}{Traditional contraception}  \\  " _n
file close table

esttab d_ct_0 d_ct_1 d_ct_2 using `tables'/appendix_timetrend.tex, append ///
    fragment ///
	nogap nolines varwidth(55)  ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( *0.* pass* _cons *assets* *educ* *agegroup*) ///
    varlabels( ///
        croplostdummy     "Crop loss --- 1-7 months" ///
    )


file open table using `tables'/appendix_timetrend.tex, write append
file write table "\addlinespace" _n
// // Dummy / fixed effects indicators
// file write table "Wave dummies                                                 &  \mco{Yes}          &  \mco{Yes}          &  \mco{Yes}    \\" _n
// file write table "Time trend interacted with wave 1 characteristics\tnote{a}   &  \mco{No}           &  \mco{Yes}          &  \mco{No}     \\" _n
// file write table "Wave dummies interacted with wave 1 characteristics\tnote{b} &  \mco{No}           &  \mco{No}           &  \mco{Yes}    \\" _n
// file write table "Woman fixed effects                                          &    \mco{Yes}        &    \mco{Yes}        &    \mco{Yes}        \\" _n
// Observations / number of women
file write table "Observations" _col(56)
foreach res in d_pr_0 d_pr_1 d_pr_2  {
    est restore `res'
    file write table "&    \mco{`e(N)'}        "
}
file write table "\\ " _n
file write table "Number of women" _col(56)
foreach res in d_pr_0 d_pr_1 d_pr_2  {
    est restore `res'
    loc numWomen = `e(N_g)' 
    file write table "&    \mco{`numWomen'}        "
}
file write table "\\ " _n
file write table "\addlinespace" _n
file write table _col(56) "&\multicolumn{3}{c}{Modern contraception}  \\  " _n
file close table

esttab d_cm_0 d_cm_1 d_cm_2 using `tables'/appendix_timetrend.tex, append ///
    fragment ///
	nogap nolines varwidth(55)  ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( *0.* pass* _cons *assets* *educ* *agegroup*) ///
    varlabels( ///
        croplostdummy     "Crop loss --- 1-7 months" ///
    )

file open table using `tables'/appendix_timetrend.tex, write append

file write table "\addlinespace" _n
// // Dummy / fixed effects indicators
// file write table "Wave dummies                                                 &  \mco{Yes}          &  \mco{Yes}          &  \mco{Yes}    \\" _n
// file write table "Time trend interacted with wave 1 characteristics\tnote{a}   &  \mco{No}           &  \mco{Yes}          &  \mco{No}     \\" _n
// file write table "Wave dummies interacted with wave 1 characteristics\tnote{b} &  \mco{No}           &  \mco{No}           &  \mco{Yes}    \\" _n
// file write table "Woman fixed effects                                          &    \mco{Yes}        &    \mco{Yes}        &    \mco{Yes}        \\" _n
// Observations / number of women
file write table "Observations" _col(56)
foreach res in d_pr_0 d_pr_1 d_pr_2  {
    est restore `res'
    file write table "&    \mco{`e(N)'}        "
}
file write table "\\ " _n
file write table "Number of women" _col(56)
foreach res in d_pr_0 d_pr_1 d_pr_2  {
    est restore `res'
    loc numWomen = `e(N_g)' 
    file write table "&    \mco{`numWomen'}        "
}
file write table "\\ " _n

// Dummy / fixed effects indicators
file write table "\addlinespace" _n
file write table "                                                             & \multicolumn{3}{c}{Model Specifications}                      \\" _n
file write table "Wave dummies                                                 &  \mco{Yes}          &  \mco{Yes}          &  \mco{Yes}    \\" _n
file write table "Time trend \X  wave 1 characteristics\tnote{a}   &  \mco{No}           &  \mco{Yes}          &  \mco{No}     \\" _n
file write table "Wave dummies \X  wave 1 characteristics\tnote{b} &  \mco{No}           &  \mco{No}           &  \mco{Yes}    \\" _n
file write table "Woman fixed effects                                          &    \mco{Yes}        &    \mco{Yes}        &    \mco{Yes}        \\" _n
file write table "\addlinespace" _n

file write table "\bottomrule" _n
file write table "\end{tabular}" _n
file write table "\begin{tablenotes} \footnotesize" _n
file write table "\item \hspace*{-0.5em} \textbf{Note.}" _n
file write table "All models are linear probability models with each panel a separate regression." _n
file write table "Robust standard errors clustered at household level in parentheses; " _n
file write table "* significant at 10\%; ** significant at 5\%; *** significant at 1\%." _n
file write table "Crop loss is a dummy for a per capita crop loss of `labCroploss'." _n
file write table "\item[a] Linear time trend interacted with assets per capita in wave 1, " _n
file write table "dummies for education levels, and dummies for age groups." _n
file write table "\item[b] Wave dummies interacted with assets per capita in wave 1, " _n
file write table "dummies for education levels, and dummies for age groups." _n
file write table "\end{tablenotes}" _n
file write table "\end{threeparttable}" _n
file write table "\end{center}" _n
file write table "\end{table}" _n
file close table


