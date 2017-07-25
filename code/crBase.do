// Create base data file
// crBase.do
// Edited: 2017-07-20

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

foreach wave of numlist 1/4 {
    merge m:1 cluster hh passage using `dataDir'/household_wave`wave'
    drop _merge
}

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

// Period dummies
tab passage, gen(pass)


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


////////////////////////////////////////
// Variable and value labels          //
////////////////////////////////////////

lab var id_hh         "Unique household identifier"
lab var id_person     "Unique individual identifier"

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

lab def new_yesno     0 "No" 1 "yes"
lab val contra_any contra_trad contra_modern any_sterilization ///
        educ_problem sp_educ_problem age_problem ///
        new_yesno    


//////////////////////////////
// Save base data set       //
//////////////////////////////

save `dataDir'/base, replace
