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


// LaTeX intro part for table
file open stats using `tables'/desstat1.tex, write replace

file write stats "\begin{table}" _n
file write stats "\centering" _n
file write stats "\footnotesize" _n
file write stats "\begin{threeparttable}" _n
file write stats "\caption{Wave 1 Descriptive Statistics for Women}" _n
file write stats "\label{tab:desc_stat_women}" _n
file write stats "\begin{tabular}{l  D{.}{.}{3,2} D{.}{.}{3,2} D{.}{.}{3,2} D{.}{.}{3,2}} \toprule" _n
file write stats "                                                    	 & \mco{Mean} 	       & 	\mco{St Dev}	  \\ \midrule" _n

file close stats


xi , noomit: estpost  sum i.agegroup if wave == 1 
esttab using `tables'/desstat1.tex , ///
    main(mean %9.3fc) aux(sd %9.3fc) ///
    varlabels( ///
        _Iagegroup_12 "Age 18-22" ///
        _Iagegroup_23 "Age 23-27" ///
        _Iagegroup_28 "Age 28-32" ///
        _Iagegroup_33 "Age 33-37" ///
        _Iagegroup_38 "Age 38-45" ///
    ) ///  
    fragment nomtitles nonumber noobs append nolines ///
    nogap varwidth(55) label wide noparentheses

file open  stats using `tables'/desstat1.tex, write append
file write stats "\addlinespace" _n
file close stats

xi , noomit: estpost  sum assets_pc_wave1 i.educ017 if wave == 1 

esttab using `tables'/desstat1.tex , ///
    main(mean %9.3fc) aux(sd %9.3fc) ///
    varlabels( ///
        _Ieduc017_0  "No education" ///
        _Ieduc017_1  "1 - 6 years of education" ///
        _Ieduc017_7  "7 plus years of education" ///
        assets_pc_wave1 "Assets per capita in wave 1 (10,000 TZS)\tnote{a}" ///
    ) ///  
    fragment nomtitles nonumber noobs append nolines ///
    nogap varwidth(55) label wide noparentheses
 
file open stats using `tables'/desstat1.tex, write append
 
file write stats "\bottomrule" _n
file write stats "\end{tabular}" _n
file write stats "\begin{tablenotes}" _n
file write stats "\scriptsize" _n
file write stats "\item[a] Assets capture self-reported values of land, livestock, business assets, durable" _n
file write stats "goods, and savings." _n
file write stats "\end{tablenotes}" _n
file write stats "\end{threeparttable}" _n
file write stats "\end{table}" _n

file close stats

exit    

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

    