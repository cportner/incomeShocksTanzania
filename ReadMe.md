# Income Shocks, Contraceptive Use, and Timing of Fertility

**Purpose:** Paper published in Journal of Development Economics, Volume 131, March 2018, Pages 96-103. Link to paper: https://doi.org/10.1016/j.jdeveco.2017.10.007

## Directory structure

You need the following directories for the code to run:

- rawData: original data files
- code: data cleaning, variables, and analysis
- data: derived data files and results
- figures: generated figures and other figures for paper
- tables: generated tables
- staticPDF: map of Kagera region

In addition, the following directories has writing in them:

- paper: the paper itself, together with snippets and notes and bibliography
- presentations: various presentations, each its own tex file
- response: response to referee and editor comments

##  Generating files

All figures, tables, and pdfs are generated by running `make`.
If you want only a specific file use `make <fileName>`, but
remember to use the directory name before file name to make it run.
See the "Makefile" in the base directory for more information 
on what files are included.

All code assume that you have Stata-SE installed and ready
to run in batch mode (Stata -> Install Terminal Utility).
Make sure you do not have your profile automatically change
working directory (something like cd ~/data for example).
If you do, make will not run the Stata files correctly.

The PDF of final paper is created using XeLaTeX with the TeX
Gyre Pagella fonts.
The fonts are freely available here:
- [Math font](http://www.gust.org.pl/projects/e-foundry/tg-math/index_html)
- [Text font](http://www.gust.org.pl/projects/e-foundry/tex-gyre/pagella)
