// Create base data file
// crIndividual_waves.do
// Edited: 2017-07-18

vers 13.1
clear

//  short file paths - assuming work directory is "code"
loc rawDir    "../rawData"
loc dataDir   "../data"
loc figureDir "../figures"

***********************************************************************************************************************
*                                Loop over waves for individual files
***********************************************************************************************************************

foreach wave of numlist 1/4 {

    * Basic demographic data
    use "`rawDir'/HOUSEHOLD/WAVE`wave'/S1___IND.DTA" 
    keep cluster hh id wave passage sex rel ageyr agemo marstat spousehh spouseid


    *Merging individual education 
    merge 1:1 cluster hh id passage using ///
        "`rawDir'/HOUSEHOLD/WAVE`wave'/S5___IND.DTA", keepusing(read write math grade grd)
    drop _merge


    *Merging individual health and creating illness variable
    merge 1:1 cluster hh id passage using ///
        "`rawDir'/HOUSEHOLD/WAVE`wave'/S6___IND.DTA", keepusing(ill illtime illunit ill6mo illdays daysout)
    drop _merge
    recode illdays (. = 0)
    gen    illdays_dummy = illdays > 1 // Creating illness dummy variable
    lab var illdays_dummy "Dummy for ill more than 1 day"


    *Merging fertility and contraceptive data by individual
    merge 1:1 cluster hh id passage using ///
        "`rawDir'/HOUSEHOLD/WAVE`wave'/S9___IND.DTA", keepusing(birthtot wmngt50 pregnant mospreg contruse method1 method2)
    drop if _merge==2  // Fertility data, but no matching demographic data
    drop _merge


    *Merging biometric data
    merge 1:1 cluster hh id passage using ///
        "`rawDir'/HOUSEHOLD/WAVE`wave'/S10__IND.DTA", keepusing(measured weight height)
    drop _merge

    * Save individual information for wave
    save "`dataDir'/individual_wave`wave'.dta", replace // Saving individual merged files for wave 1

}

