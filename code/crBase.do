// Create base data file
// crBase.do

vers 13.1
clear

//  short file paths - assuming work directory is "code"
loc rawDir    "../rawData"
loc dataDir   "../data"

//////////////////////////////
// Combining data files     //
//////////////////////////////

// Appending individual wave files to form panel

use `dataDir'/individual_wave1
foreach wave of numlist 2/4 {
    append using `dataDir'/individual_wave`wave'
}
sort cluster hh passage

// Merge in household level information
preserve
    tempfile tempHH
    use `dataDir'/household_wave1, clear
    foreach wave of numlist 2/4 {
        append using `dataDir'/household_wave`wave'
    }
    sort cluster hh passage
    save "`tempHH'"
restore
merge m:1 cluster hh passage using "`tempHH'"
drop _merge


// Merging in partner education and generate polygyny dummy

preserve
    tempfile tempEdu
    use "`rawDir'/HOUSEHOLD/WAVE1/S5___IND.DTA", clear 
    foreach wave of numlist 2/4 {
        append using "`rawDir'/HOUSEHOLD/WAVE`wave'/S5___IND.DTA"
    }
    keep cluster hh id passage schl grade grd
    rename schl  sp_schl     // Partner ever attended school
    rename grade sp_grade    // Partner's education
    rename grd   sp_grd      // Partner's education
    rename id spouseid       // Partner's id 
    // "grd" is already coded from Karega survey, but seems to miss some no school obs
    gen sp_educ_years = sp_grd
    replace sp_educ_years = 0 if sp_schl == 2 ///
        | sp_grade == "ADULTED" | sp_grade == "*******"  // never attended formal school

    // Correcting education
    // create dummy for all education values the not same for individual
    bysort cluster hh spouseid: egen sp_educ = mode(sp_educ_years)
    gen educ_temp = sp_educ != sp_educ_years
    bysort cluster hh spouseid: egen sp_educ_problem = max(educ_temp)

    // Education grouping variable based on median
    bysort cluster hh spouseid: egen educ_years_median=median(sp_educ_years)
    egen sp_educ017 = cut(educ_years_median) , at(0,1,7,25) // none, some primary, grad primary or above
    egen sp_educ07 = cut(educ_years_median) , at(0,7,25) // none and some primary, grad primary or above

    drop sp_educ educ_years_median educ_temp

    sort cluster hh spouseid passage
    save "`tempEdu'"
restore

// Spouseid is not unique across some female, hence the m:1 merge
sort cluster hh spouseid passage
merge m:1 cluster hh spouseid passage using "`tempEdu'"
drop if _merge == 2 // Otherwise there would be duplicates
drop _merge

// Polygyny dummy - needs to be done in two steps
// This works because only those who report that their spouse live in household show an id for the spouse
bysort cluster hh spouseid passage: gen nvals = _N // number of wives claiming same husband
gen polygyny = nvals > 1 & spouseid != .
// also need to update the dummy for males since they can only claim one wife
preserve
    tempfile tempPoly
    keep if polygyny
    replace id = spouseid
    keep cluster hh id passage polygyny
    duplicates drop // just need the one observation
    save "`tempPoly'"
restore
merge 1:1 cluster hh id passage using "`tempPoly'", update replace
drop _merge nvals

// Identifying which household members are no longer in the household

preserve
    tempfile tempMoved
    use "`rawDir'/HOUSEHOLD/WAVE1/S1___IND.DTA", clear
    foreach wave of numlist 2/4 {
        append using "`rawDir'/HOUSEHOLD/WAVE`wave'/S1___IND.DTA" 
    }
    keep cluster hh id passage LivnHere hhmbr  // keeping only the variables that identify that a person is still in the household
    sort cluster hh id passage
    save "`tempMoved'"
restore
merge 1:1 cluster hh id passage using "`tempMoved'"
drop _merge

// Add survey calculated total income from the surveyors
preserve
    tempfile tempIncome
    use "`rawDir'/OtherKageraData/inc___hh.dta", clear
    sort cluster hh passage
    keep cluster hh passage incagr inchh1 // total agricultural income and total household income
    save "`tempIncome'"
restore
merge m:1 cluster hh passage using "`tempIncome'"
drop _merge

drop if ageyr < 7             // Way too young (move substantial restriction later)
drop if hhmbr == 2            // Not a household member
drop if LivnHere == 2         // Prior household member but not in household this wave
drop if ageyr == . | sex == . // No reason to keep those around - not recorded for people who left the survey

drop hhmbr LivnHere

///////////////////////////////////
// Defining/redefining variables //
///////////////////////////////////

// Unique person and household identifiers
gen id_person = cluster*10000 + hh*100 + id
gen id_hh     = cluster*100 + hh
order id_hh id_person, after(id)


// Period dummies and wave count
tab passage, gen(pass)
bysort id_person (wave): gen num_waves = _N


// Fix age
// use _n instead of wave because some respondents enter our age range later than wave 1.
// this is important if we want to increase number of observations by allowing those
// who are not observed in all waves.
// We just need to get the initial age correct and use that instead of getting every age
// correct and rely on the small changes over time (not enough variation anyway)
// Age difference for 4 survey waves will be between 1 and 2 years. It should not be
// more and it cannot be zero.
// If max and min ages are 1 or 2 years apart for 4 waves then fine, use smallest as 
// initial age.
// For less than 4 waves use corresponding lower difference
bysort id_person: egen medianage = median(ageyr)
bysort id_person: egen agemin = min(ageyr)
bysort id_person: egen agemax = max(ageyr)
bysort id_person: gen numwaves = _N
gen firstage = agemin if (numwaves == 4 | numwaves == 3) ///
    & (agemax - agemin == 2 | agemax - agemin == 1)
replace firstage = agemin if numwaves == 2 & (agemax - agemin == 1 | agemax == agemin)
replace firstage = agemin if numwaves == 1
gen age_problem = firstage == .
replace firstage = int(medianage) if age_problem
// checking how many have age problems
preserve
    // hist ageyr if wave == 1 & numwaves == 4, discrete
    bysort id_person: keep if _n == 1
    tab age_problem
restore
// create age group 
egen agegroup = cut(firstage), at(12,23,28,33,38,50) // last group from 38 to 45 because relatively few in 43-45 age
drop numwaves agemin agemax medianage


// Education (respondent's - partner's come from above)

// "grd" is already coded from Karega survey, but seems to miss some no school obs
// General information on Tanzania's education system: https://www.classbase.com/countries/Tanzania/Education-System
// Also see page 30 of Interviewer's Manual
gen educ_years = grd
replace educ_years = 0 if schl == 2 ///
    | grade == "ADULTED" | grade == "*******"  // never attended formal school

// Correcting education
// create dummy for all education values the not same for individual
bysort id_person: egen educ = mode(educ_years)
gen educ_temp = educ != educ_years
bysort id_person: egen educ_problem = max(educ_temp)
// how many change enough to create problems for our definition of education?
bysort id_person: egen educmin = min(educ_years)
bysort id_person: egen educmax = max(educ_years)
gen educ_wide_vary = (educmax >= 7 & educmin < 7) | (educmax > 0 & educmax < 7 & educmin == 0)
// checking how many have education problems
preserve
    bysort id_person: keep if _n == 1
    tab educ_problem
    tab educ_wide_vary
restore

// Education grouping variable based on median
bysort id_person: egen educ_years_median=median(educ_years)
egen educ017 = cut(educ_years_median) , at(0,1,7,25) // none, some primary, grad primary or above
egen educ07 = cut(educ_years_median) , at(0,7,25) // none and some primary, grad primary or above

drop educ_wide_vary educ_years_median educ educmin educmax educ_temp


// Contraception use

sort id_person wave
// Variable for any type of contraceptive - 2 previously represented No
gen contra_any = contruse   
recode contra_any (2 = 0)
// Traditional contraceptive use
gen contra_trad = (method1 >= 1 & method1 <= 3 & method1 ~= .) ///
    | (method2 >= 1 & method2 <= 3 & method2 ~= .) ///
    if (method1 != . | method2 !=.)
// Modern contraceptive use
gen contra_modern = (method1 >= 4 & method1 ~= .) ///
    | (method2 >= 4 & method2 ~= .) ///
    if (method1 != . | method2 !=.)
replace contra_trad = 1 if contra_any & !(contra_trad | contra_modern)
replace contra_any  = 1 if contra_any == . & contra_trad != . & contra_modern != .
replace contra_trad   = 0 if contra_any == 0 & contra_trad   == .
replace contra_modern = 0 if contra_any == 0 & contra_modern == .

// No point using contraceptives while already pregnant
replace contra_any    = 0 if pregnant==1  
replace contra_trad   = 0 if pregnant==1 
replace contra_modern = 0 if pregnant==1 

// No point using contraceptives if male or female sterilization
// Code contraceptive use as missing if sterilization now or before
forvalues wave = 1/4 {
    forvalues prior = `wave'(-1)1 {
        foreach var of varlist contra_any contra_trad contra_modern {
            bysort id_person (wave): replace `var' = .  ///
                if wave == `wave' ///
                & (method1[`prior'] == 11 | method1[`prior'] == 12 ///
                | method2[`prior'] == 11 | method2[`prior'] == 12)
        }
    }
}

gen ster = method1 == 11 | method1 == 12 | method2 == 11 | method2 == 12
bysort id_person: egen any_sterilization = max(ster)
drop ster
sort id_person wave

// lag values for contraceptive
bysort id_person (wave): gen lagcontra_any    = contra_any[_n-1]
bysort id_person (wave): gen lagcontra_trad   = contra_trad[_n-1]
bysort id_person (wave): gen lagcontra_modern = contra_modern[_n-1]


// Births and pregnancies

// First time surveyed respondent asked for all prior births.
// If answer no to ever pregnant/ever birth number of children is missing
// In subsequent surveys asked only about last 6 months for continuing women
// and all births for new women.
// In both cases the variable is birthtot.
// Unfortunately, it looks like some wave numbers are recorded so
// that some women who only show up in one wave is coded as having a higher
// wave number but total number of birth is recorded.
// That presumably happens when somebody joins a household that have already
// been surveyed and therefore is not coded as wave 1.
// The fix is to create a person/wave variable and check if that works better
// If a person skips waves, it is not entirely clear what happens.
// Some appear to have been asked for new births, whereas others were clearly
// asked about total number of birth over their life.

bysort id_person (wave): gen person_wave = _n
bysort id_person (wave): gen noncon = (wave - wave[_n-1] > 1 & wave - wave[_n-1] < 4 )
bysort id_person: egen nonconsecutive = max(noncon)
drop noncon

replace birthtot = 0 if (everpreg == 2 | everbrth == 2) & birthtot == .
// New births between surveys - first survey equal to missing
gen birth = birthtot if person_wave != 1 & !nonconsecutive
bysort id_person (person_wave): gen numbirth = birthtot if _n == 1 & !nonconsecutive
forvalues wave = 2 / 4 {
    bysort id_person (person_wave): replace numbirth = numbirth[_n-1] + birth ///
    if !nonconsecutive & person_wave == `wave'
}
// Dealing with non-consecutive respondents - count births only if consecutive survey
// This still leaves a number of cases where birth and/or numbirth are missing
// because it is not clear whether the survey captured new births or total births
// or where the next reported number is too high to be new births but lower than
// the originally reported number of children
bysort id_person (wave): replace birth = birthtot ///
    if (wave[_n] == wave[_n-1] + 1) & nonconsecutive
bysort id_person (wave): replace numbirth = birthtot ///
    if _n == 1 & nonconsecutive
bysort id_person (wave): replace numbirth = birthtot ///
    if nonconsecutive & (wave[_n] > wave[_n-1] + 1) ///
    & birthtot[_n] >= birthtot[_n-1]
bysort id_person (wave): replace numbirth = numbirth[_n-1] + birthtot ///
    if (wave[_n] >= wave[_n-1] + 1) & nonconsecutive ///
    & birthtot[_n] <= birthtot[_n-1] & birthtot[_n] < 2
bysort id_person (wave): replace numbirth = numbirth[_n-1] + birth ///
    if (wave[_n] == wave[_n-1] + 1) & nonconsecutive ///
    & numbirth[_n-1] != .

// Lagged births
bysort id_person (wave): gen birth_lag  = birth[_n-1] // Gave birth 7-14 months ago
bysort id_person (wave): gen birth_lag2 = birth[_n-2] // gave birth 14-21 months ago

// Number of children prior surveys
bysort id_person (wave): gen numbirth_lag  = numbirth[_n-1]
bysort id_person (wave): gen numbirth_lag2 = numbirth_lag[_n-1]

// Pregnancy
recode pregnant (2 = 0)


// Assets variables

loc divide = 10000 // how much shocks and assets are divided by
loc strdiv "10,000" // for labels

// creating asset variable
recode shamvalu feqslamt lvsvalue bassvalu durvalue totsavng farmarea (. = 0)
gen assets=shamvalu + feqslamt + lvsvalue + bassvalu + durvalue + totsavng   
// Per capita asset measures in `strdiv' TZS
gen assets_pc      = (assets/hhmem) / `divide' // per capita assets
by id_person (wave): gen assets_pc_lag   = assets_pc[_n-1]
by id_person (wave): gen assets_pc_lag2  = assets_pc[_n-2]
// This is first wave observed; there can be differences across individuals if enter
// at different times
by id_person (wave): gen assets_pc_wave1 = assets_pc[1] 
by id_person (wave): gen landvalue_pc_wave1 = (shamvalu[1] / hhmem[1]) / `divide' 
by id_person (wave): gen landarea_wave1  = farmarea[1]


// Crop loss variables

// Crop lost per capita in `strdiv' TZS
gen croplostamount_pc     = (crlstamt / hhmem) / `divide'
by id_person (wave): gen croplostamount_pc_lag  = croplostamount_pc[_n-1]
by id_person (wave): gen croplostamount_pc_lag2 = croplostamount_pc[_n-2]


// Other health and demographic variables
gen female = sex == 2
gen heightm=height/100 //Creating height in meters
gen BMI=weight/heightm^2


////////////////////////////////////////
// Variable and value labels          //
////////////////////////////////////////

lab var id_hh         "Unique household identifier"
lab var id_person     "Unique individual identifier"
lab var person_wave   "Round individual surveyed"
lab var num_waves     "Number of waves person surveyed"

lab var polygyny      "Polygyny (imputed)"

lab var educ_years    "Education completed in years"
lab var educ017       "Education grouped (none, some primary, primary or above)"
lab var educ07        "Education grouped (none or some primary, primary or above)"
lab var educ_problem  "Education reported not identical across waves"
lab var sp_educ_years "Spouse's education in years"
lab var sp_educ017    "Spouse's education grouped (none, some primary, primary or above)"
lab var sp_educ07     "Spouse's education grouped (none or some primary, primary or above)"
lab var sp_educ_problem  "Spouse's education reported not identical across waves"

lab var firstage      "Age in first wave (possibly imputed)"
lab var age_problem   "Inconsistency in reported ages"
lab var agegroup      "Age groups based on firstage"

lab var contra_any    "Contraceptive use"
lab var contra_trad   "Contraceptive use - Traditional"
lab var contra_modern "Contraceptive use - Modern"
lab var any_sterilization "Male or female sterilization in any wave"
lab var lagcontra_any    "Contraceptive use in prior wave"
lab var lagcontra_trad   "Contraceptive use in prior wave - Traditional"
lab var lagcontra_modern "Contraceptive use in prior wave - Modern"

lab var birth         "Gave birth since last survey (1-7 months)"
lab var birth_lag     "Gave birth 7-14 months ago"
lab var birth_lag2    "Gave birth 14-21 months ago"
lab var numbirth      "Number of children ever born - current survey"
lab var numbirth_lag  "Number of children ever born - prior survey" 
lab var numbirth_lag2 "Number of children ever born - 2 surveys ago" 
lab var nonconsecutive "Not surveyed only in consecutive waves"

lab var assets              "Assets (TZS)"
lab var assets_pc           "Assets per capita (`strdiv' TZS)"
lab var assets_pc_lag       "Assets per capita prior survey (`strdiv' TZS)"
lab var assets_pc_lag2      "Assets per capita two surveys ago (`strdiv' TZS)"
lab var assets_pc_wave1     "Assets per capita in wave 1 (`strdiv' TZS)"
lab var landvalue_pc_wave1  "Land value per capita in wave 1 (`strdiv' TZS)"
lab var landarea_wave1      "Land area in wave 1"

lab var croplostamount_pc      "Crop lost per capita - last 7 months (`strdiv' TZS)"
lab var croplostamount_pc_lag  "Crop lost per capita - 7-14 months (`strdiv' TZS)"
lab var croplostamount_pc_lag2 "Crop lost per capita - 14-21 months (`strdiv' TZS)"

lab var female        "Female"
lab var heightm       "Height in metres"
lab var BMI           "BMI"


lab def newyesno     0 "No" 1 "yes"
lab val contra_any contra_trad contra_modern any_sterilization ///
        nonconsecutive pregnant ///
        illdays_dummy female ///
        educ_problem sp_educ_problem age_problem ///
        newyesno    

// Drop variables and observations
// Should remove all relevant observation for individual/household
// not just the wave

gen high_asset = assets_pc > 7000000 / `divide'
by id_person (wave): egen too_high = max(high_asset)
drop if too_high
drop high_asset too_high

//////////////////////////////
// Save base data set       //
//////////////////////////////

save `dataDir'/base, replace
