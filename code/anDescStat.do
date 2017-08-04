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

//////////////////////////////////////
// Descriptive statistics for women //
//////////////////////////////////////


// LaTeX intro part for table
file open stats using `tables'/desstat1.tex, write replace

file write stats "\begin{table}" _n
file write stats "\centering" _n
file write stats "\footnotesize" _n
file write stats "\begin{threeparttable}" _n
file write stats "\caption{Wave 1 Descriptive Statistics for Women}" _n
file write stats "\label{tab:desc_stat_women}" _n
file write stats "\begin{tabular}{l  D{.}{.}{2,3} D{.}{.}{2,3} } \toprule" _n
file write stats "                                                    	 &   \mco{Mean}        &  \mco{St Dev}    \\ \midrule" _n
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

xi , noomit: estpost  sum i.educ017 if wave == 1 
esttab using `tables'/desstat1.tex , ///
    main(mean %9.3fc) aux(sd %9.3fc) ///
    varlabels( ///
        _Ieduc017_0  "No education" ///
        _Ieduc017_1  "1 - 6 years of education" ///
        _Ieduc017_7  "7 plus years of education" ///
    ) ///  
    fragment nomtitles nonumber noobs append nolines ///
    nogap varwidth(55) label wide noparentheses


file open  stats using `tables'/desstat1.tex, write append
file write stats "\addlinespace" _n
file close stats

xi , noomit: estpost  sum assets_pc_wave1  if wave == 1 
ereturn list
esttab using `tables'/desstat1.tex , ///
    main(mean %9.3fc) aux(sd %9.3fc) ///
    varlabels( ///
        assets_pc_wave1 "Assets per capita in wave 1 (10,000 TZS)\tnote{a}" ///
    ) ///  
    fragment nomtitles nonumber noobs append nolines ///
    nogap varwidth(55) label wide noparentheses

file open  stats using `tables'/desstat1.tex, write append
file write stats "\addlinespace" _n
file write stats "Number of women" _col(56) "&                \mct{`e(N)'}         \\" _n
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

//////////////////////////////////////
// Descriptive statistics for women //
//////////////////////////////////////


// LaTeX intro part for table
file open stats using `tables'/desstat2.tex, write replace
file write stats "\begin{table}" _n
file write stats "\centering" _n
file write stats "\footnotesize" _n
file write stats "\begin{threeparttable}" _n
file write stats "\caption{Descriptive statistics for Crop loss and Outcomes}" _n
file write stats "\label{tab:desc_stat_croploss}" _n
file write stats "\begin{tabular}{l  D{.}{.}{2,3} D{.}{.}{2,3} D{.}{.}{2,3} D{.}{.}{2,3} D{.}{.}{2,3}} \toprule" _n
file write stats "                                  & \multicolumn{4}{c}{Wave} & \mco{Average} \\ \cmidrule(lr){2-5}" _n
file write stats "                                  &\multicolumn{1}{c}{1} &\multicolumn{1}{c}{2}   &\multicolumn{1}{c}{3} &\multicolumn{1}{c}{4} &   \\ \midrule" _n
file close stats

eststo clear
estpost tabstat croplostdummy  , ///
    by(wave) statistics(mean sd)  columns(statistics)

// This is needed because estpost and esttab will not print correctly if only
// a single variable is used.
matrix A = e(mean)
matrix B = e(sd)

file open  stats using `tables'/desstat2.tex, write append
file write stats "Dummy crop loss (1-7 months) $\geq$ TZS 200 " 
file write stats _col(56)
foreach x of numlist 1/5 {
    file write stats "&   " %7.2f (A[1,`x'])  "  "
}
file write stats "\\" _n    
file write stats _col(56)
foreach x of numlist 1/5 {
    file write stats "&     (" %4.2f (B[1,`x'])  ") "
}
file write stats "\\" _n    
file write stats "\addlinespace" _n
file close stats


eststo clear
estpost tabstat pregnant birth , ///
    by(wave) statistics(mean sd) columns(statistics) 

esttab using `tables'/desstat2.tex , ///
    cells(mean(fmt(2)) sd(par fmt(2))) nostar unstack ///
    varlabels( ///
        pregnant "Currently pregnant" ///
        birth    "Gave birth since last survey" ///
    ) ///
    collabels(none) mlabels(none) eqlabels(none) ///
    fragment nomtitles nonumber noobs append nolines ///
    nogap varwidth(55) label nodepvars 

file open  stats using `tables'/desstat2.tex, write append
file write stats "\addlinespace" _n
file close stats


eststo clear
estpost tabstat  contra_any contra_trad contra_modern  , ///
    by(wave) statistics(mean sd) columns(statistics) 

esttab using `tables'/desstat2.tex , ///
    cells(mean(fmt(2)) sd(par fmt(2))) nostar unstack ///
    varlabels( ///
        contra_trad   "Contraceptive use --- Traditional\tnote{a}" ///
        contra_modern "Contraceptive use --- Modern\tnote{b}" ///
    ) ///
    collabels(none) mlabels(none) eqlabels(none) ///
    fragment nomtitles nonumber noobs append nolines ///
    nogap varwidth(55) label nodepvars 


file open  stats using `tables'/desstat2.tex, write append
file write stats "\bottomrule" _n
file write stats "\end{tabular}" _n
file write stats "\begin{tablenotes} " _n
file write stats "\scriptsize" _n
file write stats "\item[a] Traditional contraceptives include abstinence and rhythm method." _n
file write stats "\item[b] Modern contraceptives include condom, diaphragm, pill, IUD, injection, female and " _n
file write stats "male sterilization." _n
file write stats "\end{tablenotes}" _n
file write stats "\end{threeparttable}" _n
file write stats "\end{table}" _n
file close stats

    