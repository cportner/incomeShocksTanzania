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
    recode crlstamt croplost (. = 0)
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
    gen livestocklost_amount = lvstlost * lvsslamt
    // retain variable labels
    foreach v of var  lvsslamt lvssdamt lvsbyamt lvstlost {
        local l`v' : variable label `v'
        if "`l`v''" == "" {
            local l`v' "`v'"
        }
    }
    //Aggregating livestock owned, lost, sold and bought by the HH
    collapse (sum) lvsslamt lvssdamt lvsbyamt lvstlost livestocklost_amount, by(cluster hh passage)  
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



