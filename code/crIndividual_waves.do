clear

loc workdir "D:\Documents\Research\Kagera Data"
loc results "D:\Documents\Research\Contraception paper"


***********************************************************************************************************************
*                                         Creating wave 1 files
***********************************************************************************************************************
use "`workdir'\Wave 1\WAVE1_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\WAVE1\S1___IND.DTA" 
keep cluster hh id wave passage sex rel ageyr agemo marstat spousehh spouseid

*Merging individual education 
sort cluster hh id passage
merge 1:1 cluster hh id passage using "`workdir'\Wave 1\WAVE1_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\WAVE1\S5___IND.DTA", keepusing(read write math grade grd)

*Merging individual health
drop _merge
sort cluster hh id passage
merge 1:1 cluster hh id passage using "`workdir'\Wave 1\WAVE1_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\WAVE1\S6___IND.DTA", keepusing(ill illtime illunit ill6mo illdays daysout)

*Creating illness variable
gen illdays2=illdays
replace illdays2=0 if missing(illdays2) // Creating illness variables with number of days
gen illdays3=illdays2
replace illdays3=1 if illdays3>1 // Creating illness dummy variable

*Merging fertility and contraceptive data by individual
sort cluster hh id passage
drop _merge
merge 1:1 cluster hh id passage using "`workdir'\Wave 1\WAVE1_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\WAVE1\S9___IND.DTA", keepusing(birthtot wmngt50 pregnant mospreg contruse method1 method2)
drop if _merge==2  // Dropping women with no ferility data

*Merging biometric data
drop _merge
sort cluster hh id passage
merge 1:1 cluster hh id passage using "`workdir'\Wave 1\WAVE1_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\WAVE1\S10__IND.DTA", keepusing(measured weight height)



*Merging farm area
drop _merge
sort cluster hh id passage
merge m:1 cluster hh passage using "`workdir'\Wave 1\WAVE1_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\S11A_OTH2.DTA"

*Merging cropping area/crop loss file
drop _merge
sort cluster hh id passage
merge m:1 cluster hh passage using "`workdir'\Wave 1\WAVE1_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\S11B_OTH2.DTA"

*Merging durable assets 
drop _merge
sort cluster hh id passage
merge m:1 cluster hh passage using "`workdir'\Wave 1\WAVE1_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\S11G_DUR2.DTA"

*Merging total livestock 
drop _merge
sort cluster hh id passage
merge m:1 cluster hh passage using "`workdir'\Wave 1\WAVE1_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\S12A_OTH2.DTA"

*Merging business asset value 
drop _merge
sort cluster hh id passage
merge m:1 cluster hh passage using "`workdir'\Wave 1\WAVE1_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\S14D_DUR2.DTA"

*Merging value of building 
drop _merge
sort cluster hh id passage
merge m:1 cluster hh passage using "`workdir'\Wave 1\WAVE1_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\S15A_DUR2.DTA"

*Merging value of durable goods 
drop _merge
sort cluster hh id passage
merge m:1 cluster hh passage using "`workdir'\Wave 1\WAVE1_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\S16A_DUR2.DTA"

*Merging value of savings 
drop _merge
sort cluster hh id passage
merge m:1 cluster hh passage using "`workdir'\Wave 1\WAVE1_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\S19C_DUR2.DTA"

save "`results'\ind_Wave1.dta", replace // Saving individual merged files for wave 1



**************************************************************************************************************************************
*                                                     Creating wave 2 files
**************************************************************************************************************************************
clear
use "`workdir'\Wave 2\WAVE2_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\WAVE2\S1___IND.DTA" 
keep cluster hh id wave passage sex rel ageyr agemo marstat spousehh spouseid

*Merging individual education
sort cluster hh id passage
merge 1:1 cluster hh id passage using "`workdir'\Wave 2\WAVE2_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\WAVE2\S5___IND.DTA", keepusing(read write math grade grd)

*Merging individual health
drop _merge
sort cluster hh id passage
merge 1:1 cluster hh id passage using "`workdir'\Wave 2\WAVE2_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\WAVE2\S6___IND.DTA", keepusing(ill illtime illunit ill6mo illdays daysout)

*Creating illness variable
gen illdays2=illdays
replace illdays2=0 if missing(illdays2)
gen illdays3=illdays2
replace illdays3=1 if illdays3>1

*Merging fertility and contraceptive data by individual
sort cluster hh id passage
drop _merge
merge 1:1 cluster hh id passage using "`workdir'\Wave 2\WAVE2_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\WAVE2\S9___IND.DTA", keepusing(birthtot wmngt50 pregnant mospreg contruse method1 method2)
drop if _merge==2  // Dropping women with no ferility data

*Merging biometric data
drop _merge
sort cluster hh id passage
merge 1:1 cluster hh id passage using "`workdir'\Wave 2\WAVE2_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\WAVE2\S10__IND.DTA", keepusing(measured weight height)


*Merging farm area
drop _merge
sort cluster hh id passage
merge m:1 cluster hh passage using "`workdir'\Wave 2\WAVE2_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\S11A_OTH2.DTA"

*Merging cropping area/loss file
drop _merge
sort cluster hh id passage
merge m:1 cluster hh passage using "`workdir'\Wave 2\WAVE2_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\S11B_OTH2.DTA"

*Merging durable assets 
drop _merge
sort cluster hh id passage
merge m:1 cluster hh passage using "`workdir'\Wave 2\WAVE2_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\S11G_DUR2.DTA"

*Merging total livestock 
drop _merge
sort cluster hh id passage
merge m:1 cluster hh passage using "`workdir'\Wave 2\WAVE2_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\S12A_OTH2.DTA"

*Merging business asset value 
drop _merge
sort cluster hh id passage
merge m:1 cluster hh passage using "`workdir'\Wave 2\WAVE2_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\S14D_DUR2.DTA"

*Merging value of building 
drop _merge
sort cluster hh id passage
merge m:1 cluster hh passage using "`workdir'\Wave 2\WAVE2_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\S15A_DUR2.DTA"

*Merging value of durable goods 
drop _merge
sort cluster hh id passage
merge m:1 cluster hh passage using "`workdir'\Wave 2\WAVE2_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\S16A_DUR2.DTA"

*Merging value of savings 
drop _merge
sort cluster hh id passage
merge m:1 cluster hh passage using "`workdir'\Wave 2\WAVE2_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\S19C_DUR2.DTA"

save "`results'\ind_Wave2", replace  // Saving individual merged files for wave 2





**************************************************************************************************************************************
*                                                      Creating wave 3 files
**************************************************************************************************************************************
clear
use "`workdir'\Wave 3\WAVE3_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\WAVE3\S1___IND.DTA" 
keep cluster hh id wave passage sex rel ageyr agemo marstat spousehh spouseid

*Merging individual education
sort cluster hh id passage
merge 1:1 cluster hh id passage using "`workdir'\Wave 3\WAVE3_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\WAVE3\S5___IND.DTA", keepusing(read write math grade grd)

*Merging individual health
drop _merge
sort cluster hh id passage
merge 1:1 cluster hh id passage using "`workdir'\Wave 3\WAVE3_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\WAVE3\S6___IND.DTA", keepusing(ill illtime illunit ill6mo illdays daysout)

*Creating illness variable
gen illdays2=illdays
replace illdays2=0 if missing(illdays2)
gen illdays3=illdays2
replace illdays3=1 if illdays3>1

*Merging fertility and contraceptive data by individual
sort cluster hh id passage
drop _merge
merge 1:1 cluster hh id passage using "`workdir'\Wave 3\WAVE3_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\WAVE3\S9___IND.DTA", keepusing(birthtot wmngt50 pregnant mospreg contruse method1 method2)
drop if _merge==2  // Dropping women with no ferility data

*Merging biometric data
drop _merge
sort cluster hh id passage
merge 1:1 cluster hh id passage using "`workdir'\Wave 3\WAVE3_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\WAVE3\S10__IND.DTA", keepusing(measured weight height)
// Dropping women with no ferility data

*Merging farm area
drop _merge
sort cluster hh id passage
merge m:1 cluster hh passage using "`workdir'\Wave 3\WAVE3_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\S11A_OTH2.DTA"

*Merging cropping area and loss file
drop _merge
sort cluster hh id passage
merge m:1 cluster hh passage using "`workdir'\Wave 3\WAVE3_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\S11B_OTH2.DTA"

*Merging durable assets 
drop _merge
sort cluster hh id passage
merge m:1 cluster hh passage using "`workdir'\Wave 3\WAVE3_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\S11G_DUR2.DTA"

*Merging total livestock 
drop _merge
sort cluster hh id passage
merge m:1 cluster hh passage using "`workdir'\Wave 3\WAVE3_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\S12A_OTH2.DTA"

*Merging business asset value 
drop _merge
sort cluster hh id passage
merge m:1 cluster hh passage using "`workdir'\Wave 3\WAVE3_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\S14D_DUR2.DTA"

*Merging value of building 
drop _merge
sort cluster hh id passage
merge m:1 cluster hh passage using "`workdir'\Wave 3\WAVE3_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\S15A_DUR2.DTA"

*Merging value of durable goods 
drop _merge
sort cluster hh id passage
merge m:1 cluster hh passage using "`workdir'\Wave 3\WAVE3_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\S16A_DUR2.DTA"

*Merging value of savings 
drop _merge
sort cluster hh id passage
merge m:1 cluster hh passage using "`workdir'\Wave 3\WAVE3_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\S19C_DUR2.DTA"

save "`results'\ind_Wave3", replace  // Saving individual merged files for wave 3






**************************************************************************************************************************************
*                                                      Creating wave 4 files
**************************************************************************************************************************************
clear
use "`workdir'\Wave 4\WAVE4_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\WAVE4\S1___IND.DTA" 
keep cluster hh id wave passage sex rel ageyr agemo marstat spousehh spouseid

*Merging individual education
sort cluster hh id passage
merge 1:1 cluster hh id passage using "`workdir'\Wave 4\WAVE4_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\WAVE4\S5___IND.DTA", keepusing(read write math grade grd)

*Merging individual health
drop _merge
sort cluster hh id passage
merge 1:1 cluster hh id passage using "`workdir'\Wave 4\WAVE4_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\WAVE4\S6___IND.DTA", keepusing(ill illtime illunit ill6mo illdays daysout)

*Creating illness variable
gen illdays2=illdays
replace illdays2=0 if missing(illdays2)
gen illdays3=illdays2
replace illdays3=1 if illdays3>1

*Merging fertility and contraceptive data by individual
sort cluster hh id passage
drop _merge
merge 1:1 cluster hh id passage using "`workdir'\Wave 4\WAVE4_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\WAVE4\S9___IND.DTA", keepusing(birthtot wmngt50 pregnant mospreg contruse method1 method2)
drop if _merge==2  // Dropping women with no ferility data

*Merging biometric data
drop _merge
sort cluster hh id passage
merge 1:1 cluster hh id passage using "`workdir'\Wave 4\WAVE4_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\WAVE4\S10__IND.DTA", keepusing(measured weight height)

*Merging farm area
drop _merge
sort cluster hh id passage
merge m:1 cluster hh passage using "`workdir'\Wave 4\WAVE4_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\S11A_OTH2.DTA"

*Merging cropping area/loss file
drop _merge
sort cluster hh id passage
merge m:1 cluster hh passage using "`workdir'\Wave 4\WAVE4_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\S11B_OTH2.DTA"

*Merging durable assets 
drop _merge
sort cluster hh id passage
merge m:1 cluster hh passage using "`workdir'\Wave 4\WAVE4_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\S11G_DUR2.DTA"

*Merging total livestock 
drop _merge
sort cluster hh id passage
merge m:1 cluster hh passage using "`workdir'\Wave 4\WAVE4_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\S12A_OTH2.DTA"

*Merging business asset value 
drop _merge
sort cluster hh id passage
merge m:1 cluster hh passage using "`workdir'\Wave 4\WAVE4_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\S14D_DUR2.DTA"

*Merging value of building 
drop _merge
sort cluster hh id passage
merge m:1 cluster hh passage using "`workdir'\Wave 4\WAVE4_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\S15A_DUR2.DTA"

*Merging value of durable goods 
drop _merge
sort cluster hh id passage
merge m:1 cluster hh passage using "`workdir'\Wave 4\WAVE4_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\S16A_DUR2.DTA"

*Merging value of savings 
drop _merge
sort cluster hh id passage
merge m:1 cluster hh passage using "`workdir'\Wave 4\WAVE4_HHDTA\LSMS_DIS\Tanzania Kagera\Public\khdsdata\HOUSEHOLD\S19C_DUR2.DTA"

save "`results'\ind_Wave4", replace  // Saving individual merged files for wave 4








