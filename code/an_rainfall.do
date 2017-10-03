// Rainfall data analysis
// anRainfall.do

vers 13.1
clear
file close _all // makes working on code easier

//  short file paths - assuming work directory is "code"
loc data   "../data"
loc tables    "../tables"

use `data'/base

// Might have to change this so using all households (ensure only 1 obs per household)
// data manipulation
include womenCommon 

// Create measures of rainfall


// convert survey date to Stata date format
replace int1yr  = int1yr + 1900
gen surveydate  = mdy(int1mo, int1day, int1yr)
gen surveymonth = ym(int1yr, int1mo)

// Average of 6 months before survey month
gen sixMonthsBefore = ym(int1yr, int1mo) - 6
sort sixMonthsBefore
sum sixMonthsBefore
loc sixMin = `r(min)'
loc sixMax = `r(max)'
gen averageRain6 = .
gen averageRain6Missing = .
foreach start of numlist `sixMin'/`sixMax' {
    loc startp5 = `start' + 5
    tempvar mean6 missing
    egen `mean6'   = rowmean(rainfall`start' - rainfall`startp5')
    egen `missing' = rowmiss(rainfall`start' - rainfall`startp5')
    replace averageRain6        = `mean6' if sixMonthsBefore == `start'
    replace averageRain6Missing = `missing' > 0 if  sixMonthsBefore == `start'
}

// Average of 12 months before survey month
gen twelveMonthsBefore = ym(int1yr, int1mo) - 12
sort twelveMonthsBefore
sum twelveMonthsBefore
loc twelveMin = `r(min)'
loc twelveMax = `r(max)'
gen averageRain12 = .
gen averageRain12Missing = .
foreach start of numlist `twelveMin'/`twelveMax' {
    loc startp11 = `start' + 11
    tempvar mean12 missing
    egen `mean12' = rowmean(rainfall`start' - rainfall`startp11')
    egen `missing' = rowmiss(rainfall`start' - rainfall`startp11') 
    replace averageRain12 = `mean12' if twelveMonthsBefore == `start'
    replace averageRain12Missing = `missing' > 0 if  twelveMonthsBefore == `start'
}



// Growing seasons - easiest to generate the growing seasons first and then 
// find the households for whom each growing season is relevant

// Extracting year and month from rainfall
dis year(dofm(348)) " " month(dofm(348))
dis year(dofm(407)) " " month(dofm(407))

foreach year of numlist 1990/1993 {
    loc gs1start = ym(`year', 2) // February start / might have to be March
    loc gs1end   = ym(`year', 5) 
    loc gs2start = ym(`year', 10)
    loc gs2end   = ym(`year', 12)
    egen gs`year'_1      = rowmean(rainfall`gs1start' - rainfall`gs1end') 
    egen gs`year'_1miss  = rowmiss(rainfall`gs1start' - rainfall`gs1end')
    egen gs`year'_2      = rowmean(rainfall`gs2start' - rainfall`gs2end')
    egen gs`year'_2miss  = rowmiss(rainfall`gs2start' - rainfall`gs2end')
    // prior 2 crop seasons 
    // one value for this year, and one value for the last from prior and first from this
    loc prior    = `year' - 1
    loc gspstart = ym(`prior', 10)
    loc gspend   = ym(`prior', 12)
    egen gs`year'_12     = rowmean(rainfall`gs1start' - rainfall`gs1end' rainfall`gs2start' - rainfall`gs2end')
    egen gs`year'_12miss = rowmiss(rainfall`gs1start' - rainfall`gs1end' rainfall`gs2start' - rainfall`gs2end')
    egen gs`year'_21     = rowmean(rainfall`gspstart' - rainfall`gspend' rainfall`gs1start' - rainfall`gs1end')
    egen gs`year'_21miss = rowmiss(rainfall`gspstart' - rainfall`gspend' rainfall`gs1start' - rainfall`gs1end')
}

// Last growing season before survey month; disregarding the one they are in
sum int1yr
loc surveyYrMin = `r(min)'
loc surveyYrMax = `r(max)'
gen lastGrowingSeason = .
gen lastGrowingSeasonMiss = .
foreach year of numlist `surveyYrMin'/`surveyYrMax' {
    loc prior = `year' - 1
    replace lastGrowingSeason     = gs`prior'_2  / 10 if int1mo <= 5 & int1yr == `year' 
    replace lastGrowingSeasonMiss = gs`prior'_2miss > 0 if int1mo <= 5 & int1yr == `year' 
    replace lastGrowingSeason     = gs`year'_1 / 10 if int1mo >= 6 & int1yr == `year'
    replace lastGrowingSeasonMiss = gs`year'_1miss > 0 if int1mo >= 6 & int1yr == `year'
}

// Prior 2 growing seasons before survey month
// Last growing season before survey month; disregarding the one they are in
sum int1yr
loc surveyYrMin = `r(min)'
loc surveyYrMax = `r(max)'
gen prior2GrowingSeason = .
gen prior2GrowingSeasonMiss = .
foreach year of numlist `surveyYrMin'/`surveyYrMax' {
    loc prior = `year' - 1
    replace prior2GrowingSeason     = gs`prior'_12 / 10    if int1mo <= 5 & int1yr == `year' 
    replace prior2GrowingSeasonMiss = gs`prior'_12miss > 0 if int1mo <= 5 & int1yr == `year' 
    replace prior2GrowingSeason     = gs`year'_21 / 10     if int1mo >= 6 & int1yr == `year' 
    replace prior2GrowingSeasonMiss = gs`year'_21miss > 0  if int1mo >= 6 & int1yr == `year' 
}

xtset cluster

// Does rainfall predict crop loss?

gen averageRain6Sq = averageRain6^2
gen averageRain12Sq = averageRain12^2
gen lastGrowingSeasonSq = lastGrowingSeason^2
gen prior2GrowingSeasonSq = prior2GrowingSeason^2

xtreg croplostdummy averageRain6 averageRain6Miss pass2 pass3 pass4 , fe cluster(cluster)
xtreg croplostdummy averageRain6 averageRain6Sq averageRain6Miss pass2 pass3 pass4 , fe cluster(cluster)

xtreg croplostdummy averageRain12 averageRain12Miss pass2 pass3 pass4 , fe cluster(cluster)
xtreg croplostdummy averageRain12 averageRain12Sq averageRain12Miss pass2 pass3 pass4 , fe cluster(cluster)

xtreg croplostdummy lastGrowingSeason lastGrowingSeasonMiss pass2 pass3 pass4 , fe cluster(cluster)
xtreg croplostdummy lastGrowingSeason lastGrowingSeasonSq lastGrowingSeasonMiss pass2 pass3 pass4 , fe  cluster(cluster)

xtreg croplostdummy prior2GrowingSeason prior2GrowingSeasonMiss pass2 pass3 pass4 , fe  cluster(cluster)
xtreg croplostdummy prior2GrowingSeason prior2GrowingSeasonSq prior2GrowingSeasonMiss pass2 pass3 pass4 , fe cluster(cluster)

xtreg croplostdummy lastGrowingSeason lastGrowingSeasonMiss averageRain6 averageRain6Miss pass2 pass3 pass4 , fe cluster(cluster)
xtreg croplostdummy lastGrowingSeason lastGrowingSeasonSq lastGrowingSeasonMiss averageRain6* pass2 pass3 pass4 , fe  cluster(cluster)


// Differentiate between passage 1 and later passage for rainfall period covered

gen averageRain = averageRain6 if passage > 1
replace averageRain = averageRain12 if passage == 1
gen averageRainSq = averageRain6Sq if passage > 1
replace averageRainSq = averageRain12Sq if passage == 1
gen averageRainMiss = averageRain6Miss if passage > 1
replace averageRainMiss = averageRain12Miss if passage == 1

xtreg croplostdummy  averageRain averageRainMiss pass2 pass3 pass4 , fe
xtreg croplostdummy  averageRain averageRainSq averageRainMiss pass2 pass3 pass4 , fe


gen growingSeason = lastGrowingSeason if passage > 1
replace growingSeason = prior2GrowingSeason if passage == 1
gen growingSeasonSq = lastGrowingSeasonSq if passage > 1
replace growingSeasonSq = prior2GrowingSeasonSq if passage == 1
gen growingSeasonMiss = lastGrowingSeasonMiss if passage > 1
replace growingSeasonMiss = prior2GrowingSeasonMiss if passage == 1

xtreg croplostdummy  growingSeason growingSeasonMiss pass2 pass3 pass4 , fe cluster(cluster)
xtreg croplostdummy  growingSeason growingSeasonSq growingSeasonMiss pass2 pass3 pass4 , fe cluster(cluster)

// Using women fixed effects lead to essentially the same results
xtset id_person
eststo last: xtreg croplostdummy lastGrowingSeason lastGrowingSeasonMiss pass2 pass3 pass4 , fe cluster(cluster)
estadd local fixed "\mco{Yes}" , replace
xtreg croplostdummy lastGrowingSeason pass2 pass3 pass4 if !lastGrowingSeasonMiss , fe cluster(cluster)

xtreg croplostdummy lastGrowingSeason lastGrowingSeasonSq lastGrowingSeasonMiss pass2 pass3 pass4 , fe cluster(cluster)

eststo expand: xtreg croplostdummy  growingSeason growingSeasonMiss pass2 pass3 pass4 , fe cluster(cluster)
estadd local fixed "\mco{Yes}" , replace
xtreg croplostdummy  growingSeason pass2 pass3 pass4 if !growingSeasonMiss , fe cluster(cluster)


xtreg croplostdummy  growingSeason growingSeasonSq growingSeasonMiss pass2 pass3 pass4 , fe cluster(cluster)

xtreg croplostamount_pc lastGrowingSeason lastGrowingSeasonMiss pass2 pass3 pass4 , fe cluster(cluster)
xtreg croplostamount_pc lastGrowingSeason lastGrowingSeasonSq lastGrowingSeasonMiss pass2 pass3 pass4 , fe cluster(cluster)
xtreg croplostamount_pc growingSeason growingSeasonMiss pass2 pass3 pass4 , fe cluster(cluster)
xtreg croplostamount_pc growingSeason growingSeasonSq growingSeasonMiss pass2 pass3 pass4 , fe cluster(cluster)

sum lastGrowingSeason growingSeason

// // Woman fixed effects - little evidence that rainfall has any effect no matter the definition
// // Note that growingSeason has not been lagged, so ignore birth results
// xtset id_person
// xtreg contra_any croplostdummy growingSeason growingSeasonMiss  pass2 pass3 pass4 , fe cluster(id_hh)
// xtreg contra_trad croplostdummy growingSeason growingSeasonMiss pass2 pass3 pass4 , fe cluster(id_hh)
// xtreg contra_mode croplostdummy  growingSeason growingSeasonMiss pass2 pass3 pass4 , fe cluster(id_hh)
// xtreg pregnant croplostdummy  growingSeason growingSeasonMiss pass2 pass3 pass4 , fe cluster(id_hh)
// xtreg birth croplostdummy_lag growingSeason growingSeasonMiss pass3 pass4 , fe cluster(id_hh)

// // Woman fixed effects - little evidence that rainfall has any effect no matter the definition
// xtset id_person
// xtreg contra_any croplostdummy growingSeason growingSeasonSq growingSeasonMiss  pass2 pass3 pass4 , fe cluster(id_hh)
// xtreg contra_trad croplostdummy growingSeason growingSeasonSq growingSeasonMiss pass2 pass3 pass4 , fe cluster(id_hh)
// xtreg contra_mode croplostdummy  growingSeason growingSeasonSq growingSeasonMiss pass2 pass3 pass4 , fe cluster(id_hh)
// xtreg pregnant croplostdummy  growingSeason growingSeasonSq growingSeasonMiss pass2 pass3 pass4 , fe cluster(id_hh)
// xtreg birth croplostdummy_lag growingSeason growingSeasonSq growingSeasonMiss pass3 pass4 , fe cluster(id_hh)

/////////////////////////////////////////////////
// Tables                                      //
/////////////////////////////////////////////////

file open table using `tables'/appendix_rainfall.tex, write replace
file write table "\begin{table}[htbp]" _n
file write table "\begin{center}" _n
file write table "\begin{small}" _n
file write table "\begin{threeparttable}" _n
file write table "\caption{Rainfall and Crop Loss}" _n
file write table "\label{tab:hours}" _n
file write table "\begin{tabular}{@{} l D{.}{.}{2.6} D{.}{.}{2.6}  @{}}" _n
file write table "\toprule" _n
file write table "                                                       &\multicolumn{2}{c}{Crop Loss} \\ \midrule " _n
file write table "                                                       & \mco{Model I}  & \mco{Model II} \\ \midrule " _n
file close table

loc models "last expand"

esttab `models'  using `tables'/appendix_rainfall.tex, append ///
    fragment ///
	nogap nolines varwidth(65) label ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( _cons *pass* ) ///
    varlabels( ///
        lastGrowingSeason     "Average monthly rainfall last prior growing season\tnote{a}" ///
        lastGrowingSeasonMiss "Dummy for missing information in last growing season" ///
        growingSeason         "Average monthly rainfall prior growing season(s)\tnote{b}" ///
        growingSeasonMiss     "Dummy for missing information in prior growing season(s)" ///
    )

file open table using `tables'/appendix_rainfall.tex, write append
file write table "\addlinespace" _n 
file close table

esttab `models' using `tables'/appendix_rainfall.tex, append ///
    indicate("Wave dummies = pass2 pass3 pass4" , labels("\mco{Yes}" "\mco{No}")) ///
    s(fixed, label("Woman fixed effects")) ///
    fragment ///
	nogap nolines varwidth(55)  ///
    collabels(none) mlabels(none) eqlabels(none) ///
    nomtitles nonumber nodepvars noobs ///
    se(3) b(3) star(* 0.10 ** 0.05 *** 0.01) ///
    drop( _cons *Season* )

// Observations / number of women
file open table using `tables'/appendix_rainfall.tex, write append
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
file write table "\begin{tablenotes} \footnotesize" _n
file write table "\item \hspace*{-0.5em} \textbf{Note.}" _n
file write table "Robust standard errors clustered at household level in parentheses; " _n
file write table "* significant at 10\%; ** significant at 5\%; *** significant at 1\%." _n
file write table "Rainfall is average monthly rainfall measured in cm." _n
file write table "Growing seasons are February-May and October-December." _n
file write table "\item[a] Captures last completed growing season before survey month, independent of wave."_n
file write table "\item[b] Captures last completed growing season before survey month, " _n
file write table "except for wave 1 where the monthly average for the last two prior" _n
file write table "completed growing seasons are used." _n
file write table "\end{tablenotes}" _n
file write table "\end{threeparttable}" _n
file write table "\end{small}" _n
file write table "\end{center}" _n
file write table "\end{table}" _n
file close table




