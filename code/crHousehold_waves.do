// Create base data file
// crHouesehold_waves.do
// Edited: 2017-07-17

vers 13.1
clear

//  short file paths - assuming work directory is "code"
loc rawDir    "../rawData"
loc dataDir   "../data"
loc figureDir "../figures"

*******************************************************************************************************************************
*                                         Loop over waves for household files
*******************************************************************************************************************************

foreach wave of numlist 1/4 {

    *Constructing aggregate household farm area and farm value file
    use "`rawDir'/HOUSEHOLD/WAVE`wave'/S11A_OTH.DTA"
    gen farmarea=shamarea * 2.457 if shaarea==2 // Converting from hectare to acre
    replace farmarea=shamarea if shaarea==1
    recode farmarea (. = 0)
    lab var farmarea "Farm area (acre) - based on S11aQ2a"
    // retain variable labels
    foreach v of var farmarea shamvalu {
        local l`v' : variable label `v'
        if "`l`v''" == "" {
            local l`v' "`v'"
        }
    }
    collapse (sum) farmarea shamvalu, by(cluster hh passage) // Aggregating all farm area used by the household
    foreach v of var farmarea shamvalu {
        label var `v' "`l`v''"
    }
    save "`dataDir'/household_wave`wave'.dta", replace


    *Constructing aggregate household crop area/loss file
    clear
    use "`rawDir'/HOUSEHOLD/WAVE`wave'/S11B_OTH.DTA" 
    replace croparea = croparea * 2.457 if crarunit==2  // Converting from hectare to acre
    recode croparea (. = 0)
    replace croplost=0 if croplost==2 // Making crop loss dummy
    gen     cropsold = cropqnty*crsalamt if crsalunt~=15  // Finding the total value of crop sold
    replace cropsold = crsalamt if crsalunt==15  // For certain crops, total value is already provided
    recode cropsold (. = 0)
    lab var cropsold "Value of crop sold"
    // retain variable labels
    foreach v of var croparea crlstamt cropsold croplost {
        local l`v' : variable label `v'
        if "`l`v''" == "" {
            local l`v' "`v'"
        }
    }
    collapse (sum) croparea crlstamt cropsold (max) croplost, by(cluster hh passage) // Finding total crop loss, crop sold and area produced
    foreach v of var croparea crlstamt cropsold croplost {
        label var `v' "`l`v''"
    }
    merge 1:1 cluster hh passage using "`dataDir'/household_wave`wave'.dta"
    drop _merge
    save "`dataDir'/household_wave`wave'.dta", replace


    *Constructing aggregate durable assets file
    clear
    use "`rawDir'/HOUSEHOLD/WAVE`wave'/S11G_DUR.DTA" 
    // retain variable labels
    foreach v of var feqslamt feqsdamt {
        local l`v' : variable label `v'
        if "`l`v''" == "" {
            local l`v' "`v'"
        }
    }
    collapse (sum) feqslamt feqsdamt , by(cluster hh passage) // Aggregating equipment value owned and sold
    foreach v of var feqslamt feqsdamt {
        label var `v' "`l`v''"
    }
    merge 1:1 cluster hh passage using "`dataDir'/household_wave`wave'.dta"
    drop _merge
    save "`dataDir'/household_wave`wave'.dta", replace


    *Constructing aggregate livestock file
    clear
    use "`rawDir'/HOUSEHOLD/WAVE`wave'/S12A_OTH.DTA" 
    // retain variable labels
    foreach v of var  lvsslamt lvssdamt lvsbyamt lvstlost {
        local l`v' : variable label `v'
        if "`l`v''" == "" {
            local l`v' "`v'"
        }
    }
    collapse (sum) lvsslamt lvssdamt lvsbyamt lvstlost, by(cluster hh passage)  //Aggregating livestock owned, lost, sold and bought by the HH
    foreach v of var  lvsslamt lvssdamt lvsbyamt lvstlost {
        label var `v' "`l`v''"
    }
    rename lvsslamt lvsvalue
    merge 1:1 cluster hh passage using "`dataDir'/household_wave`wave'.dta"
    drop _merge
    save "`dataDir'/household_wave`wave'.dta", replace


    *Constructing aggregate household business asset value file
    clear
    use "`rawDir'/HOUSEHOLD/WAVE`wave'/S14D_DUR.DTA" 
    // retain variable labels
    foreach v of var bassvalu {
        local l`v' : variable label `v'
        if "`l`v''" == "" {
            local l`v' "`v'"
        }
    }
    collapse (sum) bassvalu, by(cluster hh passage)
    foreach v of var bassvalu {
        label var `v' "`l`v''"
    }
    merge 1:1 cluster hh passage using "`dataDir'/household_wave`wave'.dta"
    drop _merge
    save "`dataDir'/household_wave`wave'.dta", replace


    *Constructing aggregate value of building/house file
    clear
    use "`rawDir'/HOUSEHOLD/WAVE`wave'/S15A_DUR.DTA" 
    // retain variable labels
    foreach v of var bldvalue {
        local l`v' : variable label `v'
        if "`l`v''" == "" {
            local l`v' "`v'"
        }
    }
    replace bldvalue = 0 if bldown != 1 // Considering building values only for the buildings owned by the HH
    collapse (sum) bldvalue, by(cluster hh passage)
    foreach v of var bldvalue {
        label var `v' "`l`v''"
    }
    merge 1:1 cluster hh passage using "`dataDir'/household_wave`wave'.dta"
    drop _merge
    save "`dataDir'/household_wave`wave'.dta", replace


    *Constructing aggregate durable goods value file
    clear
    use "`rawDir'/HOUSEHOLD/WAVE`wave'/S16A_DUR.DTA" 
    // retain variable labels
    foreach v of var durvalue {
        local l`v' : variable label `v'
        if "`l`v''" == "" {
            local l`v' "`v'"
        }
    }
    collapse (sum) durvalue, by(cluster hh passage)  // Aggregating value of durable goods
    foreach v of var durvalue {
        label var `v' "`l`v''"
    }
    merge 1:1 cluster hh passage using "`dataDir'/household_wave`wave'.dta"
    drop _merge
    save "`dataDir'/household_wave`wave'.dta", replace


    *Constructing total savings
    clear
    use "`rawDir'/HOUSEHOLD/WAVE`wave'/S19C_IND.DTA" 
    // retain variable labels
    foreach v of var totsavng {
        local l`v' : variable label `v'
        if "`l`v''" == "" {
            local l`v' "`v'"
        }
    }
    collapse (sum) totsavng, by(cluster hh passage)  // Aggregating total savings/cash holdings
    foreach v of var totsavng {
        label var `v' "`l`v''"
    }
    merge 1:1 cluster hh passage using "`dataDir'/household_wave`wave'.dta"
    drop _merge
    save "`dataDir'/household_wave`wave'.dta", replace
    
    
    * Creating number of household members by aggregating all members living in household 
    clear
    use "`rawDir'/HOUSEHOLD/WAVE`wave'/S1___IND.DTA", clear 
    gen hhmem=1
    collapse (sum) hhmem, by(cluster hh passage)
    lab var hhmem "Total number of household members"
    merge 1:1 cluster hh passage using "`dataDir'/household_wave`wave'.dta"
    drop _merge  
    save "`dataDir'/household_wave`wave'.dta", replace

}


exit

***********************************************************************************************************************
* Creating files appended over all 4 waves, so that they can be merged with the final base file
***********************************************************************************************************************

*Using the total household income data appended for all 4 rounds of the survey by the surveyors
use "`workdir'\Wave 4\CONSTRUCTED_FILES\LSMS_DIS\Tanzania Kagera\Public\khdsaggr\inc___hh.dta", clear
gen incagrm=incagr/7   //Dividing total agricultural income by number of months
gen inchh1m= inchh1/7  //Dividing total household income by number of months
sort cluster hh passage
keep cluster hh passage incagr inchh1
save "`results'\Income.dta", replace



*Appending education level for all spouses so that it can be merged with the base file for women*
use "`workdir'\Wave 1\WAVE1_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\WAVE1\S5___IND.DTA", clear 
append using "`workdir'\Wave 2\WAVE2_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\WAVE2\S5___IND.DTA"
append using "`workdir'\Wave 3\WAVE3_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\WAVE3\S5___IND.DTA" 
append using "`workdir'\Wave 4\WAVE4_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\WAVE4\S5___IND.DTA"
keep cluster hh id passage grade
rename grade sp_grade    // Differentiating partner's education
rename id spouseid       // Differentiating partner's id 
save "`results'\male_grade.DTA", replace


*********************************************************************************************************************
*Identifying household members that are no longer part of the household (moved)
*********************************************************************************************************************
use "`workdir'\Wave 1\WAVE1_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\WAVE1\S1___IND.DTA", clear
append using "D:\Documents\Research\Kagera Data\Wave 2\WAVE2_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\WAVE2\S1___IND.DTA" "D:\Documents\Research\Kagera Data\Wave 3\WAVE3_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\WAVE3\s1___ind.dta" "D:\Documents\Research\Kagera Data\Wave 4\WAVE4_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\WAVE4\S1___IND.DTA"
keep cluster hh id passage LivnHere hhmbr // keeping only the variables that identify that a person is still in the household
sort cluster hh id passage
save "`results'\Moved.dta", replace


