// Create base data file
// crIndividual_waves.do
// Edited: 2017-07-25

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
    keep cluster hh id wave passage sex rel ageyr marstat spousehh spouseid


    *Merging individual education 
    merge 1:1 cluster hh id passage using ///
        "`rawDir'/HOUSEHOLD/WAVE`wave'/S5___IND.DTA", keepusing(read write math schl grade grd)
    drop _merge


    *Merging individual health and creating illness variable
    merge 1:1 cluster hh id passage using ///
        "`rawDir'/HOUSEHOLD/WAVE`wave'/S6___IND.DTA", keepusing(ill illtime illunit ill6mo illdays daysout)
    drop if _merge == 2 // Illness data, but no matching demographic data
    drop _merge
    recode illdays (. = 0)
    gen    illdays_dummy = illdays > 1 // Creating illness dummy variable
    lab var illdays_dummy "Dummy for ill more than 1 day"

    * Merging time use data from section 7
    merge 1:1 cluster hh id passage using "`rawDir'/HOUSEHOLD/WAVE`wave'/S7A__IND.DTA", keepusing(empld7 ag7 se7)
    drop if _merge==2
    drop _merge
    
    merge 1:1 cluster hh id passage using "`rawDir'/HOUSEHOLD/WAVE`wave'/S7B__IND.DTA", keepusing(emplmnt1 empl1mo empl1tu empl1we empl1th empl1fr empl1sa empl1su  empltime emwhyoff emplmnt2 empl2mo empl2tu empl2we empl2th empl2fr empl2sa empl2su )
    drop if _merge==2
    drop _merge

    merge 1:1 cluster hh id passage using "`rawDir'/HOUSEHOLD/WAVE`wave'/S7C__IND.DTA", keepusing(farmed7 farmedmo farmedtu farmedwe farmedth farmedfr farmedsa farmedsu facmty facmtymo facmtytu facmtywe facmtyth facmtyfr facmtysa facmtysu prhrsmo prhrstu prhrswe prhrsth prhrsfr prhrssa prhrssu herdhrmo herdhrtu herdhrwe herdhrth herdhrfr herdhrsa herdhrsu heprodmo heprodtu heprodwe heprodth heprodfr heprodsa heprodsu)
    drop if _merge==2
    drop _merge

    merge 1:1 cluster hh id passage using "`rawDir'/HOUSEHOLD/WAVE`wave'/S7D__IND.DTA", keepusing(se1hrsmo se1hrstu se1hrswe se1hrsth se1hrsfr se1hrssa se1hrssu se2hrsmo se2hrstu se2hrswe se2hrsth se2hrsfr se2hrssa se2hrssu se3hrsmo se3hrstu se3hrswe se3hrsth se3hrsfr se3hrssa se3hrssu)
    drop if _merge==2
    drop _merge

    merge 1:1 cluster hh id passage using "`rawDir'/HOUSEHOLD/WAVE`wave'/S7E__IND.DTA"
    drop if _merge==2
    drop _merge


    *Merging fertility and contraceptive data by individual
    merge 1:1 cluster hh id passage using ///
        "`rawDir'/HOUSEHOLD/WAVE`wave'/S9___IND.DTA", ///
        keepusing(everpreg everbrth birthtot wmngt50 pregnant mospreg contruse method1 method2)
    drop if _merge==2  // Fertility data, but no matching demographic data
    drop _merge


    *Merging biometric data
    merge 1:1 cluster hh id passage using ///
        "`rawDir'/HOUSEHOLD/WAVE`wave'/S10__IND.DTA", keepusing(measured weight height)
    drop _merge

    * Save individual information for wave
    save "`dataDir'/individual_wave`wave'.dta", replace // Saving individual merged files for wave 1

}

