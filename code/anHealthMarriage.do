// Health and marriage results
// anHealthMarriage.do

vers 13.1
clear
file close _all // makes working on code easier

//  short file paths - assuming work directory is "code"
loc data   "../data"
loc tables    "../tables"

use `data'/base

xtset id_person


keep if female 
drop if nonconsecutive

tempvar min_age max_age 

by id_person: egen `min_age' = min(ageyr)
drop if `min_age' < 17
by id_person: egen `max_age' = max(ageyr)
drop if `max_age' > 45

// drop if any missing marriage status or if widowed in current or prior periods
tempvar miss_marstat widow everwidowed
by id_person: egen `miss_marstat' = count(marstat)
by id_person: drop if `miss_marstat' < _N

gen `everwidowed' = .
gen `widow' = marstat == 5
replace `everwidowed' = `widow' == 1 if wave == 1
foreach wave of numlist 2/4 {
    by id_person (wave): replace `everwidowed' = `widow' == 1 | `everwidowed'[_n-1] == 1 if wave == `wave'
}
drop if `everwidowed' == 1


/////////////////////////////////
// Recode and create variables //
/////////////////////////////////

// recode contra* pregnant (. = 0)

tab cluster, gen(area)


// --------------------------------------------------------------------------
// General marital status
// Dissolution of partnership, husband in household, and shocks
// --------------------------------------------------------------------------


// Coding
// 0 is married/partnered
// > 0 is never married, divorced, widowed, etc
// Positive effects of crop loss is indicative of less likely to be married

tab marstat, m

gen dissolved = marstat == 3 | marstat == 4 if marstat != . // not married or partnered
gen married   = marstat <  3 if marstat != . // married or partnered



//////////////////////////////////
// Marriage results             //
//////////////////////////////////

// general marriage status

// eststo generalMarriage: xtreg married croplostdummy pass2 pass3 pass4 , fe cluster(id_hh)
// xtreg married croplostdummy croplostdummy_lag  pass3 pass4 , fe cluster(id_hh)

// divorce and dissolution

// Drop waves with never married or reporting never married in prior waves
tempvar notmarried nevermarried 
gen `nevermarried' = .
gen `notmarried'   = marstat == 6
foreach wave of numlist 4/1 {
    by id_person (wave): replace `nevermarried' = `notmarried' == 1 | `nevermarried'[_n+1] == 1 if wave == `wave'
}
drop if `nevermarried' == 1

// conditions - married/partnered first time observed
gen marriedPeriod1 = married == 1 if passage == 1
bysort id_person (passage): egen inSample = max(marriedPeriod1)
keep if inSample

eststo divorce: xtreg dissolve croplostdummy pass3 pass4 if passage != 1 , fe cluster(id_hh)
sum dissolve, meanonly
loc mean_dissolve = `r(mean)'
// xtreg dissolve croplostdummy croplostdummy_lag pass3 pass4 if passage != 1 , fe cluster(id_hh)


// --------------------------------------------------------------------------
// Absence of partner/husband and crop loss shocks
// --------------------------------------------------------------------------


// Back to our regular sample
use `data'/base, clear

// data manipulation
include womenCommon 

// Impact of crop loss amount on whether the spouse is currently living in the Household
gen absent = spousehh == 2 if spousehh != .
eststo absent: xtreg absent croplostdummy pass2 pass3 pass4, fe cluster(id_hh)
sum absent, meanonly
loc mean_absent = `r(mean)'


// --------------------------------------------------------------------------
// BMI and illness impact from crop loss shocks
// --------------------------------------------------------------------------

eststo bmi: xtreg BMI croplostdummy pregnant pass2 pass3 pass4 , fe cluster(id_hh)
sum BMI, meanonly
loc mean_bmi = `r(mean)'
eststo ill: xtreg illdays_dummy croplostdummy  pass2 pass3 pass4 , fe cluster(id_hh)
sum illdays_dummy, meanonly
loc mean_ill = `r(mean)'



/////////////////////////////////////////////////
// Tables                                      //
/////////////////////////////////////////////////

file open table using `tables'/main_health_marriage.tex, write replace
file write table "\begin{table}[htbp]" _n
file write table "\begin{center}" _n
file write table "\begin{threeparttable}" _n
file write table "\caption{The Effects of Crop Loss on Women's Health, Absence of Partner, and Marriage Dissolution}" _n
file write table "\label{tab:health}" _n
file write table "\begin{tabular}{@{} l D{.}{.}{2.6} D{.}{.}{2.6}  @{}}" _n
file write table "\toprule" _n
file write table "                                                       & \mct{Respondent} \\" _n
file write table "                                                       & \mco{BMI\tnote{a}}  & \mco{Illness\tnote{b}}      \\ \midrule" _n
file close table
// BMI and illness
esttab bmi ill  using `tables'/main_health_marriage.tex, append ///
    fragment ///
	nogap nolines varwidth(55) label ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop(_cons  *pass*) ///
    varlabels( ///
        pregnant "Pregnant" ///
    )
file open table using `tables'/main_health_marriage.tex, write append
file write table "\addlinespace " _n
file write table "Wave dummies                                           &    \mco{Yes}        &    \mco{Yes}        \\" _n
file write table "Woman fixed effects                                    &    \mco{Yes}        &    \mco{Yes}        \\" _n
file write table "Observations" _col(56)
foreach res in bmi ill  {
    est restore `res'
    file write table "&    \mco{`e(N)'}        "
}
file write table "\\ " _n
file write table "Number of women" _col(56)
foreach res in bmi ill {
    est restore `res'
    loc numWomen = `e(N_g)' 
    file write table "&    \mco{`numWomen'}        "
}
file write table "\\ " _n
// Spouse absent and dissolution
file write table "\addlinespace " _n
file write table "                                                       &\mco{Absence/migration}   &\mco{Dissolution of}\\" _n
file write table "                                                       &\mco{of partner\tnote{c}} &\mco{of marriage\tnote{d}}\\ \midrule" _n
file close table
esttab absent divorce using `tables'/main_health_marriage.tex, append ///
    fragment ///
	nogap nolines varwidth(55) label ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop(_cons  *pass*) 
file open table using `tables'/main_health_marriage.tex, write append
file write table "\addlinespace " _n
file write table "Wave dummies                                           &    \mco{Yes}        &    \mco{Yes}        \\" _n
file write table "Woman fixed effects                                    &    \mco{Yes}        &    \mco{Yes}        \\" _n
file write table "Observations" _col(56)
foreach res in absent divorce  {
    est restore `res'
    file write table "&    \mco{`e(N)'}        "
}
file write table "\\ " _n
file write table "Number of women" _col(56)
foreach res in absent divorce {
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
file write table "Each panel a separate regression." _n
file write table "Robust standard errors clustered at household level in parentheses; " _n
file write table "* significant at 10\%; ** significant at 5\%; *** significant at 1\%." _n
file write table "\item[a] BMI was unavailable for some women in the original sample." _n
file write table "These women are kept in the sample. Average BMI across all observations is " %6.2f (`mean_bmi') "." _n
file write table "\item[b] Dependent variable is whether the respondent has been ill for two or more" _n
file write table "days over the last 6 months. The mean of the dependent variable is " %6.3f (`mean_ill') "." _n
file write table "\item[c] Dependent variable is whether the respondent's spouse is absent from" _n
file write table "the household. The mean of the dependent variable is " %6.3f (`mean_absent') "." _n
file write table "\item[d] Dependent variable is whether the respondent reports either" _n
file write table _char(96) _char(96) "separated" _char(39) _char(39) " or " _char(96) _char(96) "divorced"_char(39) _char(39) " as marital status." _n 
file write table "The sample for the dissolution of marriage is conditional on being married when first "_n
file write table "surveyed and includes women who are dropped" _n
file write table "from the main sample because they do not show up in all four survey rounds" _n
file write table "or because they are not partnered in all four survey rounds." _n
file write table "The mean of the dependent variable is " %6.3f (`mean_dissolve') "." _n
file write table "\end{tablenotes}" _n
file write table "\end{threeparttable}" _n
file write table "\end{center}" _n
file write table "\end{table}" _n
file close table
