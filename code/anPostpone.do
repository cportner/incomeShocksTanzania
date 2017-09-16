// Examine whether there is postponement or reduction of fertility
// anPostpone.do

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

// // OLS - base specification without wave 1 asset interaction
// loc xvar = " assets_pc_wave1 i.educ017 i.agegroup "
// eststo lpm_ca_0: reg contra_any croplostdummy  pass2 pass3 pass4 `xvar', cluster(id_hh)
// estadd local fixed "\mco{No}" , replace
// eststo lpm_ct_0: reg contra_trad croplostdummy  pass2 pass3 pass4 `xvar', cluster(id_hh)
// estadd local fixed "\mco{No}" , replace
// eststo lpm_cm_0: reg contra_mode croplostdummy  pass2 pass3 pass4 `xvar', cluster(id_hh)
// estadd local fixed "\mco{No}" , replace
// eststo lpm_pr_0: reg pregnant croplostdummy  pass2 pass3 pass4 `xvar', cluster(id_hh)
// estadd local fixed "\mco{No}" , replace
// eststo lpm_br_0: reg birth croplostdummy_lag  pass3 pass4 `xvar', cluster(id_hh)
// estadd local fixed "\mco{No}" , replace
// 
// // Community fixed effects - base specification without wave 1 asset interaction
// loc xvar = " assets_pc_wave1 i.educ017 i.agegroup i.cluster"
// eststo lpm_ca_1: reg contra_any croplostdummy  pass2 pass3 pass4 `xvar', cluster(id_hh)
// estadd local fixed "\mco{No}" , replace
// eststo lpm_ct_1: reg contra_trad croplostdummy  pass2 pass3 pass4 `xvar', cluster(id_hh)
// estadd local fixed "\mco{No}" , replace
// eststo lpm_cm_1: reg contra_mode croplostdummy  pass2 pass3 pass4 `xvar', cluster(id_hh)
// estadd local fixed "\mco{No}" , replace
// eststo lpm_pr_1: reg pregnant croplostdummy  pass2 pass3 pass4 `xvar', cluster(id_hh)
// estadd local fixed "\mco{No}" , replace
// eststo lpm_br_1: reg birth croplostdummy_lag  pass3 pass4 `xvar', cluster(id_hh)
// estadd local fixed "\mco{No}" , replace

// Woman fixed effects base specification without wave 1 asset interaction
eststo d_ca_0: xtreg contra_any croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_ca_1: xtreg contra_any croplostdummy croplostdummy_lag   pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_ca_2: xtreg contra_any croplostdummy croplostdummy_lag croplostdummy_lag2 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_ca_3: reg contra_any croplostdummy croplostdummy_lag croplostdummy_lag2 croplostdummy_lag3  , cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace

eststo d_ct_0: xtreg contra_trad croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_ct_1: xtreg contra_trad croplostdummy croplostdummy_lag  pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_ct_2: xtreg contra_trad croplostdummy croplostdummy_lag croplostdummy_lag2 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_ct_3: reg contra_trad croplostdummy croplostdummy_lag croplostdummy_lag2 croplostdummy_lag3  , cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace

eststo d_cm_0: xtreg contra_mode croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_cm_1: xtreg contra_mode croplostdummy croplostdummy_lag pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_cm_2: xtreg contra_mode croplostdummy croplostdummy_lag croplostdummy_lag2 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_cm_3: reg contra_mode croplostdummy croplostdummy_lag croplostdummy_lag2 croplostdummy_lag3  , cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace

eststo lpm_pr_0: reg pregnant croplostdummy  pass2 pass3 pass4 `xvar', cluster(id_hh)
estadd local fixed "\mco{No}" , replace
eststo d_pr_0: xtreg pregnant croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace

eststo lpm_pr_1: reg pregnant croplostdummy croplostdummy_lag pass3 pass4 `xvar', cluster(id_hh)
estadd local fixed "\mco{No}" , replace
eststo d_pr_1: xtreg pregnant croplostdummy croplostdummy_lag pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace

eststo lpm_pr_2: reg pregnant croplostdummy croplostdummy_lag croplostdummy_lag2 pass4 `xvar', cluster(id_hh)
estadd local fixed "\mco{No}" , replace
eststo d_pr_2: xtreg pregnant croplostdummy croplostdummy_lag croplostdummy_lag2 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace

eststo d_pr_3: reg pregnant croplostdummy croplostdummy_lag croplostdummy_lag2 croplostdummy_lag3 `xvar', cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace

eststo lpm_br_0: reg birth croplostdummy_lag  pass3 pass4 `xvar', cluster(id_hh)
estadd local fixed "\mco{No}" , replace
eststo d_br_0: xtreg birth  croplostdummy_lag  pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace

eststo lpm_br_1: reg birth croplostdummy_lag croplostdummy_lag2 pass4 `xvar', cluster(id_hh)
estadd local fixed "\mco{No}" , replace
eststo d_br_1: xtreg birth croplostdummy_lag croplostdummy_lag2 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace

eststo d_br_2: reg birth  croplostdummy_lag croplostdummy_lag2 croplostdummy_lag3 `xvar', cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace

// Interaction version

eststo d_ca_0: xtreg contra_any i.croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_ca_1: xtreg contra_any i.croplostdummy i.croplostdummy_lag   pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_ca_2: xtreg contra_any croplostdummy##croplostdummy_lag   pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace


eststo d_ct_0: xtreg contra_trad i.croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_ct_1: xtreg contra_trad i.croplostdummy i.croplostdummy_lag  pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_ct_2: xtreg contra_trad croplostdummy##croplostdummy_lag  pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace


eststo d_cm_0: xtreg contra_mode i.croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_cm_1: xtreg contra_mode i.croplostdummy i.croplostdummy_lag pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_cm_2: xtreg contra_mode croplostdummy##croplostdummy_lag pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace


eststo d_pr_0: xtreg pregnant i.croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_pr_1: xtreg pregnant i.croplostdummy i.croplostdummy_lag pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_pr_2: xtreg pregnant croplostdummy##croplostdummy_lag pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace


eststo d_br_0: xtreg birth  i.croplostdummy_lag  pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_br_1: xtreg birth i.croplostdummy_lag i.croplostdummy_lag2  pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo d_br_2: xtreg birth croplostdummy_lag##croplostdummy_lag2  pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace


/////////////////////////////////////////////////
// Tables                                      //
/////////////////////////////////////////////////


// Pregnancy and birth table

file open table using `tables'/appendix_postpone_birth.tex, write replace
file write table "\begin{table}[htbp]" _n
file write table "\begin{center}" _n
file write table "\begin{threeparttable}" _n
file write table "\caption{Effects of Lagged Crop Loss on Pregnancy and Birth}" _n
file write table "\label{tab:postpone_birth}" _n
file write table "\begin{tabular}{@{} l D{.}{.}{1.5} D{.}{.}{1.5} D{.}{.}{1.5} @{}}" _n
file write table "\toprule" _n
file write table "                                                       &                     &                     & \mco{With Lag and}   \\ " _n
file write table "                                                       & \mco{Original}      & \mco{With Lag}      & \mco{Interaction}    \\ " _n
file write table "\midrule" _n
file write table "                                                       & \multicolumn{3}{c}{Currently pregnant} \\  " _n
file close table

// Pregnancy

esttab d_pr_0 d_pr_1 d_pr_2 using `tables'/appendix_postpone_birth.tex, append ///
    fragment ///
	nogap nolines varwidth(55)  ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( *0.* pass* _cons) ///
    varlabels( ///
        1.croplostdummy     "Crop loss --- 1-7 months" ///
        1.croplostdummy_lag "Crop loss --- 7-14 months" ///
        1.croplostdummy#1.croplostdummy_lag "Crop loss (1-7 months) \X crop loss (7-14 months)" ///
    )
    
file open table using `tables'/appendix_postpone_birth.tex, write append
file write table "\addlinespace" _n
// Dummy / fixed effects indicators
file write table "Wave dummies                                           &  \mco{Yes\tnote{a}} &  \mco{Yes\tnote{b}} &  \mco{Yes\tnote{b}} \\" _n
file write table "Woman fixed effects                                    &    \mco{Yes}        &    \mco{Yes}        &    \mco{Yes}        \\" _n
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

esttab d_br_0 d_br_1 d_br_2 using `tables'/appendix_postpone_birth.tex, append ///
    fragment ///
	nogap nolines varwidth(55)  ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( *0.* pass* _cons) ///
    varlabels( ///
        1.croplostdummy      "Crop loss --- 1-7 months" ///
        1.croplostdummy_lag  "Crop loss --- 7-14 months" ///
        1.croplostdummy_lag2 "Crop loss --- 14-21 months" ///
        1.croplostdummy_lag#1.croplostdummy_lag2 "Crop loss (7-14 months) \X crop loss (14-21 months)" ///
    )

file open table using `tables'/appendix_postpone_birth.tex, write append
file write table "\addlinespace" _n
// Dummy / fixed effects indicators
file write table "Wave dummies                                           &  \mco{Yes\tnote{b}} &  \mco{Yes\tnote{c}} &  \mco{Yes\tnote{c}} \\" _n
file write table "Woman fixed effects                                    &    \mco{Yes}        &    \mco{Yes}        &    \mco{Yes}        \\" _n
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


file write table "\bottomrule" _n
file write table "\end{tabular}" _n
file write table "\begin{tablenotes} \footnotesize" _n
file write table "\item \hspace*{-0.5em} \textbf{Note.}" _n
file write table "All models are linear probability models." _n
file write table "Robust standard errors clustered at household level in parentheses; " _n
file write table "* significant at 10\%; ** significant at 5\%; *** significant at 1\%." _n
file write table "Crop loss is a dummy for a per capita crop loss of `labCroploss'." _n
file write table "\item[a] Dummies for waves 2, 3, and 4." _n
file write table "\item[b] Dummies for waves 3 and 4." _n
file write table "\item[c] Dummy for wave 4." _n
file write table "\end{tablenotes}" _n
file write table "\end{threeparttable}" _n
file write table "\end{center}" _n
file write table "\end{table}" _n
file close table

    

// Contraceptive use table

file open table using `tables'/appendix_postpone_contraceptives.tex, write replace
file write table "\begin{table}[htbp]" _n
file write table "\begin{center}" _n
file write table "\begin{threeparttable}" _n
file write table "\caption{Effects of Lagged Crop Loss on Contraceptive Use Overall and By Type}" _n
file write table "\label{tab:postpone_contraceptive}" _n
file write table "\begin{tabular}{@{} l D{.}{.}{2.6}  D{.}{.}{2.6} D{.}{.}{2.6}  @{}}" _n
file write table "\toprule" _n
file write table "                                                       &                     &                     & \mco{With Lag and}   \\ " _n
file write table "                                                       & \mco{Original}      & \mco{With Lag}      & \mco{Interaction}    \\ " _n
file write table "\midrule" _n
file write table "                                                       & \multicolumn{3}{c}{Any contraception}  \\ " _n

file close table

esttab d_ca_0 d_ca_1 d_ca_2 using `tables'/appendix_postpone_contraceptives.tex, append ///
    fragment ///
	nogap nolines varwidth(55)  ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( *0.* pass* _cons) ///
    varlabels( ///
        1.croplostdummy     "Crop loss --- 1-7 months" ///
        1.croplostdummy_lag "Crop loss --- 7-14 months" ///
        1.croplostdummy#1.croplostdummy_lag "Crop loss (1-7 months) \X crop loss (7-14 months)" ///
    )

file open table using `tables'/appendix_postpone_contraceptives.tex, write append
file write table "\addlinespace" _n
file write table _col(56) "&\multicolumn{3}{c}{Traditional contraception}  \\  " _n
file close table

esttab d_ct_0 d_ct_1 d_ct_2 using `tables'/appendix_postpone_contraceptives.tex, append ///
    fragment ///
	nogap nolines varwidth(55)  ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( *0.* pass* _cons) ///
    varlabels( ///
        1.croplostdummy     "Crop loss --- 1-7 months" ///
        1.croplostdummy_lag "Crop loss --- 7-14 months" ///
        1.croplostdummy#1.croplostdummy_lag "Crop loss (1-7 months) \X crop loss (7-14 months)" ///
    )

file open table using `tables'/appendix_postpone_contraceptives.tex, write append
file write table "\addlinespace" _n
file write table _col(56) "&\multicolumn{3}{c}{Modern contraception}  \\  " _n
file close table

esttab d_cm_0 d_cm_1 d_cm_2 using `tables'/appendix_postpone_contraceptives.tex, append ///
    fragment ///
	nogap nolines varwidth(55)  ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( *0.* pass* _cons) ///
    varlabels( ///
        1.croplostdummy     "Crop loss --- 1-7 months" ///
        1.croplostdummy_lag "Crop loss --- 7-14 months" ///
        1.croplostdummy#1.croplostdummy_lag "Crop loss (1-7 months) \X crop loss (7-14 months)" ///
    )

file open table using `tables'/appendix_postpone_contraceptives.tex, write append

file write table "\addlinespace" _n
// Dummy / fixed effects indicators
file write table "Wave dummies                                           &  \mco{Yes\tnote{a}} &  \mco{Yes\tnote{b}} &  \mco{Yes\tnote{b}} \\" _n
file write table "Woman fixed effects                                    &    \mco{Yes}        &    \mco{Yes}        &    \mco{Yes}        \\" _n
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

file write table "\bottomrule" _n
file write table "\end{tabular}" _n
file write table "\begin{tablenotes} \footnotesize" _n
file write table "\item \hspace*{-0.5em} \textbf{Note.}" _n
file write table "All models are linear probability models." _n
file write table "Robust standard errors clustered at household level in parentheses; " _n
file write table "* significant at 10\%; ** significant at 5\%; *** significant at 1\%." _n
file write table "Crop loss is a dummy for a per capita crop loss of `labCroploss'." _n
file write table "\item[a] Dummies for waves 2, 3, and 4." _n
file write table "\item[b] Dummies for waves 3 and 4." _n
file write table "\end{tablenotes}" _n
file write table "\end{threeparttable}" _n
file write table "\end{center}" _n
file write table "\end{table}" _n
file close table


