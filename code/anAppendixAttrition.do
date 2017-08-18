// anAppendixAttrition.do

vers 13.1
clear
file close _all // makes working on code easier

//  short file paths - assuming work directory is "code"
loc data   "../data"
loc tables    "../tables"

use `data'/base

/////////////////////////////////////////////////
// Dropping observations that are never usable //
/////////////////////////////////////////////////

keep if female 

preserve
bysort id_person: keep if _n == 1
count
restore

tempvar max_marstat min_age max_age firstWave notEligible maxNotEligible ///
    miss_birth miss_preg miss_cont miss_trad miss_mod miss_crop

by id_person: egen `min_age' = min(ageyr)
drop if `min_age' < 18
by id_person: egen `max_age' = max(ageyr)
drop if `max_age' > 45

preserve
bysort id_person: keep if _n == 1
count
restore

// Must be present in wave 1 to count as attrition
bysort id_person (wave): egen `firstWave' = min(wave)
drop if `firstWave' != 1

preserve
bysort id_person: keep if _n == 1
count
restore

// Women who are divorced, separated, widow or never married in first period.
// These women would not be part of the starting sample and allows us to 
// focus on attrition, i.e. women who for some reason is not observed in all 
// four periods.
gen `notEligible' = marstat >= 3 & wave == 1
bysort id_person (wave): egen `maxNotEligible' = max(`notEligible')
drop if `maxNotEligible'

preserve
bysort id_person: keep if _n == 1
count
restore

// missing important information
bysort id_person: gen numwaves = _N
by id_person: egen `miss_birth' = count(birthtot)
by id_person: egen `miss_preg'  = count(pregnant)
by id_person: egen `miss_cont'  = count(contra_any)
by id_person: egen `miss_trad'  = count(contra_trad)
by id_person: egen `miss_mod'   = count(contra_modern)
by id_person: egen `miss_crop'  = count(crlstamt)
drop if `miss_birth' < numwaves | `miss_preg' < numwaves ///
    | `miss_cont' < numwaves | `miss_trad' < numwaves | `miss_mod' < numwaves ///
    | `miss_crop' < numwaves

preserve
bysort id_person: keep if _n == 1
count
restore

/////////////////////////////////////////////////////////////
// Actual attrition - those who change marital status in a //
// subsequent period or is simply not observed             //
/////////////////////////////////////////////////////////////

// change in marital status
gen changeStatus = marstat >= 3 & wave != 1
bysort id_person (wave): egen maxChangeStatus = max(changeStatus)

// drop those who are in the regular sample
drop if numwaves == 4 & !maxChangeStatus

preserve
bysort id_person: keep if _n == 1
count
loc attritionTotal = `r(N)'
dis "Number of women dropped because of attrition: " `attritionTotal'
restore

// Count how many of each type of attrition

preserve
drop if maxChangeStatus 
bysort id_person: keep if _n == 1
count
dis "Number of women dropped because of marital status change: " `attritionTotal' - `r(N)'
restore

preserve
drop if numwaves != 4
bysort id_person: keep if _n == 1
count
dis "Number of women dropped because of not 4 waves: " `attritionTotal' - `r(N)'
restore


/////////////////////////////////
// Recode and create variables //
/////////////////////////////////

// All copied from womenCommon.do

// recode contra* pregnant (. = 0)

tab cluster, gen(area)

// Create dummy crop loss
loc divide = 10000
loc strdiv "10,000"
loc cutoff = 200/`divide' // Remember to change this if we re-do units in crBase.do
gen croplostdummy = croplostamount_pc >= `cutoff' if croplostamount_pc != .
gen croplostdummy_lag  = croplostamount_pc_lag >= `cutoff' if croplostamount_pc_lag != .
gen croplostdummy_lag2 = croplostamount_pc_lag2 >= `cutoff' if croplostamount_pc_lag2 != .

// Crop loss interactions
gen croplostXassets_w1 = croplostamount_pc * assets_pc_wave1
gen croplost_lagXassets_w1 = croplostamount_pc_lag * assets_pc_wave1
gen croplostdummyXassets_w1 = croplostdummy * assets_pc_wave1
gen croplostdummy_lagXassets_w1 = croplostdummy_lag * assets_pc_wave1
tab agegroup, gen(agegp)
foreach var of varlist agegp* {
    gen croplostdummyX`var' = croplostdummy * `var'
    gen croplostdummy_lagX`var' = croplostdummy_lag * `var'
}

// Log version
gen ln_croplostamount_pc = log(croplostamount_pc+1)
gen ln_croplostamount_pc_lag = log(croplostamount_pc_lag+1)
gen ln_croplostXassets_w1 = ln_croplostamount_pc * assets_pc_wave1
gen ln_croplost_lagXassets_w1 = ln_croplostamount_pc_lag * assets_pc_wave1
gen ln_croplostXln_assets_w1 = ln_croplostamount_pc * log(assets_pc_wave1*`divide'+1)
gen ln_croplost_lagXln_assets_w1 = ln_croplostamount_pc_lag * log(assets_pc_wave1*`divide'+1)


////////////////////////////////////////////////////
// Labels                                         //
////////////////////////////////////////////////////

loc strcut = `cutoff'*`divide'
lab var croplostdummy "Crop loss --- 1-7 months (`strcut' TZS or above)"
lab var croplostdummy_lag "Crop loss --- 7-14 months (`strcut' TZS or above)"
lab var croplostdummyXassets_w1 "Crop loss --- 1-7 months \X initial assets (`strdiv' TZS)"
lab var croplostdummy_lagXassets_w1 "Crop loss --- 7-14 months \X initial assets (`strdiv' TZS)"

// Linear version
lab var croplostamount_pc       "Crop loss --- 1-7 months (`strdiv' TZS)"
lab var croplostamount_pc_lag   "Crop loss --- 7-14 months (`strdiv' TZS)"
lab var croplostXassets_w1      "Crop loss --- 1-7 months \X initial assets (`strdiv' TZS)"
lab var croplost_lagXassets_w1  "Crop loss --- 7-14 months \X initial assets (`strdiv' TZS)"

// Log version
lab var ln_croplostamount_pc "Log crop loss --- 1-7 months"
lab var ln_croplostamount_pc_lag "Log crop loss --- 7-14 months"
lab var ln_croplostXassets_w1      "Log crop loss --- 1-7 months \X initial assets (`strdiv' TZS)"
lab var ln_croplost_lagXassets_w1  "Log crop loss --- 7-14 months \X initial assets (`strdiv' TZS)"
lab var ln_croplostXln_assets_w1      "Log crop loss --- 1-7 months \X log initial assets"
lab var ln_croplost_lagXln_assets_w1  "Log crop loss --- 7-14 months \X log initial assets"




//////////////////////////////////////
// Descriptive statistics on shocks //
//////////////////////////////////////



// LaTeX intro part for table
file open stats using `tables'/appendix_desstat1.tex, write replace

file write stats "\begin{table}[htbp]" _n
file write stats "\centering" _n
file write stats "\footnotesize" _n
file write stats "\begin{threeparttable}" _n
file write stats "\caption{Wave 1 Descriptive Statistics for Women Not in Main Sample}" _n
file write stats "\label{tab:desc_stat_women}" _n
file write stats "\begin{tabular}{l  D{.}{.}{2,3} D{.}{.}{2,3} } \toprule" _n
file write stats "                                                    	 &   \mco{Mean}        &  \mco{St Dev}    \\ \midrule" _n
file close stats


xi , noomit: estpost  sum i.agegroup if wave == 1 
esttab using `tables'/appendix_desstat1.tex , ///
    main(mean %9.3fc) aux(sd %9.3fc) ///
    varlabels( ///
        _Iagegroup_12 "Age 18-22" ///
        _Iagegroup_23 "Age 23-27" ///
        _Iagegroup_28 "Age 28-32" ///
        _Iagegroup_33 "Age 33-37" ///
        _Iagegroup_38 "Age 38-45" ///
    ) ///  
    fragment nomtitles nonumber noobs append nolines ///
    nogap varwidth(55) label wide noparentheses

file open  stats using `tables'/appendix_desstat1.tex, write append
file write stats "\addlinespace" _n
file close stats

xi , noomit: estpost  sum i.educ017 if wave == 1 
esttab using `tables'/appendix_desstat1.tex , ///
    main(mean %9.3fc) aux(sd %9.3fc) ///
    varlabels( ///
        _Ieduc017_0  "No education" ///
        _Ieduc017_1  "1 - 6 years of education" ///
        _Ieduc017_7  "7 plus years of education" ///
    ) ///  
    fragment nomtitles nonumber noobs append nolines ///
    nogap varwidth(55) label wide noparentheses


file open  stats using `tables'/appendix_desstat1.tex, write append
file write stats "\addlinespace" _n
file close stats

xi , noomit: estpost  sum assets_pc_wave1  if wave == 1 
ereturn list
esttab using `tables'/appendix_desstat1.tex , ///
    main(mean %9.3fc) aux(sd %9.3fc) ///
    varlabels( ///
        assets_pc_wave1 "Assets per capita in wave 1 (10,000 TZS)\tnote{a}" ///
    ) ///  
    fragment nomtitles nonumber noobs append nolines ///
    nogap varwidth(55) label wide noparentheses

file open  stats using `tables'/appendix_desstat1.tex, write append
file write stats "\addlinespace" _n
file write stats "Number of women" _col(56) "&                \mct{`e(N)'}         \\" _n
file write stats "\bottomrule" _n
file write stats "\end{tabular}" _n
file write stats "\begin{tablenotes}" _n
file write stats "\scriptsize" _n
file write stats "\item \hspace*{-0.5em} \textbf{Note.}" _n
file write stats "Sample consists of women aged 18 to 45, who would have been in" _n
file write stats "the main sample, but are either not observed in all periods " _n
file write stats "and/or experience at least one change in marital status over the four waves." _n
file write stats "\item[a] Assets capture self-reported values of land, livestock, business assets, durable" _n
file write stats "goods, and savings." _n
file write stats "\end{tablenotes}" _n
file write stats "\end{threeparttable}" _n
file write stats "\end{table}" _n

file close stats

/////////////////////////////////////////
// Descriptive statistics across waves //
/////////////////////////////////////////


// LaTeX intro part for table
file open stats using `tables'/appendix_desstat2.tex, write replace
file write stats "\begin{table}[htbp]" _n
file write stats "\centering" _n
file write stats "\footnotesize" _n
file write stats "\begin{threeparttable}" _n
file write stats "\caption{Descriptive statistics for Crop loss and Outcomes Across Waves for Women Not in Main Sample}" _n
file write stats "\label{tab:desc_stat_croploss}" _n
file write stats "\begin{tabular}{l  D{.}{.}{2,3} D{.}{.}{2,3} D{.}{.}{2,3} D{.}{.}{2,3} D{.}{.}{2,3}} \toprule" _n
file write stats "                                  & \multicolumn{4}{c}{Wave} & \mco{Average} \\ \cmidrule(lr){2-5}" _n
file write stats "                                  &\multicolumn{1}{c}{1} &\multicolumn{1}{c}{2}   &\multicolumn{1}{c}{3} &\multicolumn{1}{c}{4} &   \\ \midrule" _n
file close stats

eststo clear
estpost tabstat croplostdummy  , ///
    by(wave) statistics(mean sd)  columns(statistics)

// This is needed because estpost and esttab will not print correctly if only
// a single variable is used.
matrix A = e(mean)
matrix B = e(sd)

file open  stats using `tables'/appendix_desstat2.tex, write append
file write stats "Dummy crop loss (1-7 months) $\geq$ TZS 200 " 
file write stats _col(56)
foreach x of numlist 1/5 {
    file write stats "&   " %7.2f (A[1,`x'])  "  "
}
file write stats "\\" _n    
file write stats _col(56)
foreach x of numlist 1/5 {
    file write stats "&     (" %4.2f (B[1,`x'])  ") "
}
file write stats "\\" _n    
file write stats "\addlinespace" _n
file close stats


eststo clear
estpost tabstat pregnant birth , ///
    by(wave) statistics(mean sd) columns(statistics) 

esttab using `tables'/appendix_desstat2.tex , ///
    cells(mean(fmt(2)) sd(par fmt(2))) nostar unstack ///
    varlabels( ///
        pregnant "Currently pregnant" ///
        birth    "Gave birth since last survey" ///
    ) ///
    collabels(none) mlabels(none) eqlabels(none) ///
    fragment nomtitles nonumber noobs append nolines ///
    nogap varwidth(55) label nodepvars 

file open  stats using `tables'/appendix_desstat2.tex, write append
file write stats "\addlinespace" _n
file close stats


eststo clear
estpost tabstat  contra_any contra_trad contra_modern  , ///
    by(wave) statistics(mean sd) columns(statistics) 

esttab using `tables'/appendix_desstat2.tex , ///
    cells(mean(fmt(2)) sd(par fmt(2))) nostar unstack ///
    varlabels( ///
        contra_trad   "Contraceptive use --- Traditional\tnote{a}" ///
        contra_modern "Contraceptive use --- Modern\tnote{b}" ///
    ) ///
    collabels(none) mlabels(none) eqlabels(none) ///
    fragment nomtitles nonumber noobs append nolines ///
    nogap varwidth(55) label nodepvars 


file open  stats using `tables'/appendix_desstat2.tex, write append
// Number of observations in each wave
file write stats "\addlinespace" _n
file write stats "Number of women" _col(56) 
foreach wave of numlist 1/4 {
    sum contra_any if wave == `wave'
    file write stats "&  \mco{`r(N)'}  "
}
file write stats "&       \\" _n
file write stats "\bottomrule" _n
file write stats "\end{tabular}" _n
file write stats "\begin{tablenotes} " _n
file write stats "\scriptsize" _n
file write stats "\item \hspace*{-0.5em} \textbf{Note.}" _n
file write stats "Sample consists of women aged 18 to 45, who would have been in" _n
file write stats "the main sample, but are either not observed in all periods " _n
file write stats "and/or experience at least one change in marital status over the four waves." _n
file write stats "\item[a] Traditional contraceptives include abstinence and rhythm method." _n
file write stats "\item[b] Modern contraceptives include condom, diaphragm, pill, IUD, injection, female and " _n
file write stats "male sterilization." _n
file write stats "\end{tablenotes}" _n
file write stats "\end{threeparttable}" _n
file write stats "\end{table}" _n
file close stats

    