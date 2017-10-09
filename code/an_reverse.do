// Do contraceptive use, pregnancy, or birth predict shocks?
// anReverse.do

vers 13.1
clear
file close _all // makes working on code easier

//  short file paths - assuming work directory is "code"
loc data   "../data"
loc tables    "../tables"

use `data'/base

// data manipulation
include womenCommon 

bysort id_person (passage): gen pregnant_lag = pregnant[_n-1]

gen lagcontra_anyXassets = lagcontra_any * assets_pc_wave1
gen lagpregnantXassets   = pregnant_lag * assets_pc_wave1
gen lagbirthXassets      = birth_lag * assets_pc_wave1

lab var lagcontra_any        "Used contraceptives prior survey"
lab var lagcontra_anyXassets "Used contraceptives prior survey \X initial assets"
lab var pregnant_lag         "Was pregnant prior survey"
lab var lagpregnantXassets   "Pregnant prior survey \X initial assets"
lab var lagbirth             "Birth prior survey"
lab var lagbirthXassets      "Birth prior survey \X initial assets"


/////////////////////////////////////////////////////////////////////
// Does contraceptive predict shocks?                              //
/////////////////////////////////////////////////////////////////////

eststo contra1: xtreg croplostdummy lagcontra_any pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo contra2: xtreg croplostdummy lagcontra_any lagcontra_anyXassets pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo contra3: xtreg ln_croplostamount_pc lagcontra_any pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo contra4: xtreg ln_croplostamount_pc lagcontra_any lagcontra_anyXassets pass3 pass4 , fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace


/////////////////////////////////////////////////////////////////////
// Does pregnancy predict shocks?                                  //
/////////////////////////////////////////////////////////////////////


eststo preg1: xtreg croplostdummy pregnant_lag pass3 pass4, fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo preg2: xtreg croplostdummy pregnant_lag lagpregnantXassets pass3 pass4, fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo preg3: xtreg ln_croplostamount_pc pregnant_lag pass3 pass4, fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo preg4: xtreg ln_croplostamount_pc pregnant_lag lagpregnantXassets pass3 pass4, fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace



/////////////////////////////////////////////////////////////////////
// Does birth predict shocks?                                      //
/////////////////////////////////////////////////////////////////////

eststo birth1: xtreg croplostdummy birth_lag pass4, fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo birth2: xtreg croplostdummy birth_lag lagbirthXassets  pass4, fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo birth3: xtreg ln_croplostamount_pc birth_lag pass4, fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace
eststo birth4: xtreg ln_croplostamount_pc birth_lag lagbirthXassets  pass4, fe cluster(id_hh)
estadd local fixed "\mco{Yes}" , replace




/////////////////////////////////////////////////
// Tables                                      //
/////////////////////////////////////////////////


file open table using `tables'/appendix_reverse.tex, write replace
file write table "\begin{table}[htbp]" _n
file write table "\begin{center}" _n
file write table "\begin{small}" _n
file write table "\begin{threeparttable}" _n
file write table "\caption{The Association between Prior Fertility and Contraceptive Use and Current Crop Loss}" _n
file write table "\label{tab:reverse}" _n
file write table "\begin{tabular}{@{} l D{.}{.}{2.6}  D{.}{.}{2.6}  @{}}" _n
file write table "\toprule" _n
file write table "                                                       &\multicolumn{1}{c}{Crop loss - Dummy }& \multicolumn{1}{c}{} \\" _n
file write table "                                                       &\multicolumn{1}{c}{`labCroploss'}       & \multicolumn{1}{c}{Log crop loss} \\ \midrule" _n
file close table

// Births

loc models "birth1 birth3"

file open table using `tables'/appendix_reverse.tex, write append
file write table "                                                       & \multicolumn{2}{c}{Prior birth} \\" _n
file close table

esttab `models' using `tables'/appendix_reverse.tex, append ///
    fragment ///
	nogap nolines varwidth(55) label ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( _cons *pass* ) ///
    varlabels( ///
    )

file open table using `tables'/appendix_reverse.tex, write append
file write table "\addlinespace" _n 
file close table

esttab `models' using `tables'/appendix_reverse.tex, append ///
    indicate("Wave dummies =  pass4" , labels("\mco{Yes}" "\mco{No}")) ///
    s(fixed, label("Woman fixed effects")) ///
    fragment ///
	nogap nolines varwidth(55)  ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( _cons *birth*)

// Observations / number of women
file open table using `tables'/appendix_reverse.tex, write append
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
file close table


// Pregnancies

loc models "preg1 preg3"

file open table using `tables'/appendix_reverse.tex, write append
file write table "\addlinespace" _n 
file write table "                                                       & \multicolumn{2}{c}{Prior pregnancy} \\" _n
file close table

esttab `models'  using `tables'/appendix_reverse.tex, append ///
    fragment ///
	nogap nolines varwidth(55) label ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( _cons *pass* ) ///
    varlabels( ///
    )

file open table using `tables'/appendix_reverse.tex, write append
file write table "\addlinespace" _n 
file close table

esttab `models' using `tables'/appendix_reverse.tex, append ///
    indicate("Wave dummies = pass3 pass4" , labels("\mco{Yes}" "\mco{No}")) ///
    s(fixed, label("Woman fixed effects")) ///
    fragment ///
	nogap nolines varwidth(55)  ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( _cons *preg*)

// Observations / number of women
file open table using `tables'/appendix_reverse.tex, write append
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
file close table


// Contraception

loc models "contra1 contra3"

file open table using `tables'/appendix_reverse.tex, write append
file write table "\addlinespace" _n 
file write table "                                                       & \multicolumn{2}{c}{Prior contraception use} \\" _n
file close table

esttab `models'  using `tables'/appendix_reverse.tex, append ///
    fragment ///
	nogap nolines varwidth(55) label ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( _cons *pass* ) ///
    varlabels( ///
    )

file open table using `tables'/appendix_reverse.tex, write append
file write table "\addlinespace" _n 
file close table

esttab `models' using `tables'/appendix_reverse.tex, append ///
    indicate("Wave dummies = pass3 pass4" , labels("\mco{Yes}" "\mco{No}")) ///
    s(fixed, label("Woman fixed effects")) ///
    fragment ///
	nogap nolines varwidth(55)  ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( _cons *contra*)

// Observations / number of women
file open table using `tables'/appendix_reverse.tex, write append
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
file close table


// General table notes
file open table using `tables'/appendix_reverse.tex, write append
file write table "\bottomrule" _n
file write table "\end{tabular}" _n
file write table "\begin{tablenotes} \footnotesize" _n
file write table "\item \hspace*{-0.5em} \textbf{Note.}" _n
file write table "Each panel a separate regression." _n
file write table "Two left columns are linear probability models and two right columns " _n
file write table "are linear models. " _n
file write table "Robust standard errors clustered at household level in parentheses; " _n
file write table "* significant at 10\%; ** significant at 5\%; *** significant at 1\%." _n
file write table "Crop loss is a dummy for a per capita crop loss of `labCroploss'." _n
file write table "Log crop loss is log per capita crop loss plus 1." _n
// file write table "Initial assets are assets per capita in round 1 of the survey and are measured in `labAsset'." _n
file write table "\end{tablenotes}" _n
file write table "\end{threeparttable}" _n
file write table "\end{small}" _n
file write table "\end{center}" _n
file write table "\end{table}" _n
file close table

