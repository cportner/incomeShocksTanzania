// Code common to all standard women based analyses
// womenCommon.do

////////////////////////////////////////////////////////////////////////////////////////////////
// Load data & restrict to females married/partnered & all 4 rounds below age 45 and above 18 //
////////////////////////////////////////////////////////////////////////////////////////////////

keep if female & num_waves == 4

tempvar max_marstat min_age max_age ///
    miss_birth miss_preg miss_cont miss_trad miss_mod miss_crop

by id_person: egen `max_marstat' = max(marstat)
drop if `max_marstat' >= 3

by id_person: egen `min_age' = min(ageyr)
drop if `min_age' < 17
by id_person: egen `max_age' = max(ageyr)
drop if `max_age' > 45


// missing important information
by id_person: egen `miss_birth' = count(birthtot)
by id_person: egen `miss_preg'  = count(pregnant)
by id_person: egen `miss_cont'  = count(contra_any)
by id_person: egen `miss_trad'  = count(contra_trad)
by id_person: egen `miss_mod'   = count(contra_modern)
by id_person: egen `miss_crop'  = count(crlstamt)
drop if `miss_birth' < 4 
drop if `miss_preg'  < 4 
drop if `miss_cont'  < 4  // These are all sterilization cases
drop if `miss_trad'  < 4  // One woman
drop if `miss_mod'   < 4  // - None -
drop if `miss_crop'  < 4
    
xtset id_person


/////////////////////////////////
// Recode and create variables //
/////////////////////////////////

// recode contra* pregnant (. = 0)

tab cluster, gen(area)

