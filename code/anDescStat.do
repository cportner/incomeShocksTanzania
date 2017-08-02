// Descriptive statistics
// anDescStat.do

vers 13.1
clear

//  short file paths - assuming work directory is "code"
loc data   "../data"
loc tables "../tables"

use `data'/base

// data manipulation
do womenCommon 

////////////////////////////
// Descriptive statistics //
////////////////////////////

xi , noomit: estpost  sum assets_pc_wave1 i.educ017 i.agegroup if wave == 1 

esttab using `tables'/desstat1.tex , ///
    cells("mean(fmt(2)) sd(fmt(2)) ") ///
    varlabels( ///
        _Ieduc017_0  "No education" ///
        _Ieduc017_1  "1 - 6 years of education" ///
        _Ieduc017_7  "7 plus years of education" ///
        _Iagegroup_16 "Age 18-22" ///
        _Iagegroup_23 "Age 23-27" ///
        _Iagegroup_28 "Age 28-32" ///
        _Iagegroup_33 "Age 33-37" ///
        _Iagegroup_38 "Age 38-45" ///
    ) ///  
    stats(N , fmt(0) label("Number of women")) ///
    nogap nolines varwidth(55) label ///
    nomtitle nonumber replace

sum assets_pc_wave1 if wave == 1, detail

eststo clear

estpost tabstat croplostdummy contra_any contra_trad contra_modern pregnant birth , ///
    by(wave) statistics(mean sd) columns(statistics) listwise


esttab using `tables'/desstat2.tex , ///
    main(mean 2) aux(sd 2) nostar unstack ///
    varlabels( ///
        pregnant "Currently pregnant" ///
    ) ///
    nogap nolines varwidth(55) label ///
    noobs nonote nomtitle nonumber replace

    