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

foreach year of numlist 1989/1993 {
    loc gs1start = ym(`year', 2) // February start / might have to be March
    loc gs1end   = ym(`year', 5) 
    loc gs2start = ym(`year', 10)
    loc gs2end   = ym(`year', 12)
    egen gs`year'_1     = rowmean(rainfall`gs1start' - rainfall`gs1end')
    egen gs`year'_1miss = rowmiss(rainfall`gs1start' - rainfall`gs1end')
    egen gs`year'_2     = rowmean(rainfall`gs2start' - rainfall`gs2end')
    egen gs`year'_2miss = rowmiss(rainfall`gs2start' - rainfall`gs2end')
}

// Last growing season before survey month; disregarding the one they are in
sum int1yr
loc surveyYrMin = `r(min)'
loc surveyYrMax = `r(max)'
gen lastGrowingSeason = .
gen lastGrowingSeasonMiss = .
foreach year of numlist `surveyYrMin'/`surveyYrMax' {
    loc prior = `year' - 1
    replace lastGrowingSeason     = gs`prior'_2  if int1mo <= 5 & int1yr == `year' 
    replace lastGrowingSeasonMiss = gs`prior'_2miss > 0 if int1mo <= 5 & int1yr == `year' 
    replace lastGrowingSeason     = gs`year'_1 if int1mo >= 6 & int1yr == `year'
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
    replace prior2GrowingSeason     = gs`prior'_2 + gs`prior'_1 if int1mo <= 5 & int1yr == `year' 
    replace prior2GrowingSeasonMiss = gs`prior'_2miss > 0 | gs`prior'_1miss > 0 if int1mo <= 5 & int1yr == `year' 
    replace prior2GrowingSeason     = gs`year'_1 + gs`prior'_2 if int1mo >= 6 & int1yr == `year' 
    replace prior2GrowingSeasonMiss = gs`year'_1miss > 0 | gs`prior'_2miss > 0 if int1mo >= 6 & int1yr == `year' 
}

xtset cluster

// Does rainfall predict crop loss?

gen averageRain6sq = averageRain6^2
gen averageRain12sq = averageRain12^2
gen lastGrowingSeasonSq = lastGrowingSeason^2
gen prior2GrowingSeasonSq = prior2GrowingSeason^2

xtreg croplostdummy averageRain6 averageRain6Miss i.passage , fe
xtreg croplostdummy averageRain6 averageRain6sq averageRain6Miss i.passage , fe

xtreg croplostdummy averageRain12 averageRain12Miss i.passage , fe
xtreg croplostdummy averageRain12 averageRain12sq averageRain12Miss i.passage , fe

xtreg croplostdummy lastGrowingSeason lastGrowingSeasonMiss i.passage , fe
xtreg croplostdummy lastGrowingSeason lastGrowingSeasonSq lastGrowingSeasonMiss i.passage , fe

xtreg croplostdummy prior2GrowingSeason prior2GrowingSeasonMiss i.passage , fe
xtreg croplostdummy prior2GrowingSeason prior2GrowingSeasonSq prior2GrowingSeasonMiss i.passage , fe


// Differentiate between passage 1 and later passage for rainfall period covered

gen averageRain = averageRain6 if passage > 1
replace averageRain = averageRain12 if passage == 1
gen averageRainSq = averageRain6sq if passage > 1
replace averageRainSq = averageRain12sq if passage == 1
gen averageRainMiss = averageRain6Miss if passage > 1
replace averageRainMiss = averageRain12Miss if passage == 1

xtreg croplostdummy  averageRain averageRainMiss i.passage , fe
xtreg croplostdummy  averageRain averageRainSq averageRainMiss i.passage , fe


gen growingSeason = lastGrowingSeason if passage > 1
replace growingSeason = prior2GrowingSeason if passage == 1
gen growingSeasonSq = lastGrowingSeasonSq if passage > 1
replace growingSeasonSq = prior2GrowingSeasonSq if passage == 1
gen growingSeasonMiss = lastGrowingSeasonMiss if passage > 1
replace growingSeasonMiss = prior2GrowingSeasonMiss if passage == 1

xtreg croplostdummy  growingSeason growingSeasonMiss i.passage , fe
xtreg croplostdummy  growingSeason growingSeasonSq growingSeasonMiss i.passage , fe



