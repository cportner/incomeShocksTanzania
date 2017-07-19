### Makefile for Income Shocks, Contraceptive Use, and Timing of Fertility Project        ###
### and tables are hardcoded into tex file          			###
### The non-generated figures are not included here 			###

### The reason for the weird set-up is to have Makefile 
### in base directory and run LaTeX in the paper directory 
### without leaving all the other files in the base directory

# environments for files and file name
TEXFILE = incomeShocks-jde-r1
RESFILE = response-jde-1
TEX  = ./paper
RES  = ./response
FIG  = ./figures
TAB  = ./tables
COD  = ./code
RAW  = ./rawData
DAT  = ./data
MAP  = ./staticPDF

### LaTeX part

# need to add analysis dependencies to end of next line
$(TEX)/$(TEXFILE).pdf: $(TEX)/$(TEXFILE).tex $(TEX)/$(TEXFILE).bib $(MAP)/kagera.pdf $(DAT)/base.dta
	cd $(TEX); xelatex $(TEXFILE)
	cd $(TEX); bibtex $(TEXFILE)
	cd $(TEX); xelatex $(TEXFILE)
	cd $(TEX); xelatex $(TEXFILE)
	
$(RES)/$(RESFILE).pdf: $(RES)/$(RESFILE).tex $(TEX)/$(TEXFILE).bib
	cd $(RES); xelatex $(RESFILE)
	cd $(RES); bibtex $(RESFILE)
	cd $(RES); xelatex $(RESFILE)
	cd $(RES); xelatex $(RESFILE)

.PHONY: view
view: $(TEX)/$(TEXFILE).pdf
	open -a Skim $(TEX)/$(TEXFILE).pdf & 

.PHONY: response
response: $(RES)/$(RESFILE).pdf
	open -a Skim $(RES)/$(RESFILE).pdf & 


### Stata part         			                                ###

# Create base data set(s)
# Need "end" file as outcome, here the base data sets for each survey
# "%" is a pattern substitution; it looks at the target file and then uses the same
# pattern in dependencies. This works because another file depends on a list of all
# the household data files.

$(DAT)/base.dta: $(COD)/crBase.do $(DAT)/household_wave1.dta $(DAT)/household_wave2.dta \
 $(DAT)/household_wave3.dta $(DAT)/household_wave4.dta \
 $(DAT)/individual_wave1.dta $(DAT)/individual_wave2.dta \
 $(DAT)/individual_wave3.dta $(DAT)/individual_wave4.dta
	cd $(COD); stata-se -b -q crBase.do    

$(DAT)/individual_wave%.dta: $(COD)/crIndividual_waves.do $(RAW)/HOUSEHOLD/WAVE%/S11A_OTH.DTA \
 $(RAW)/HOUSEHOLD/WAVE%/S1___IND.DTA $(RAW)/HOUSEHOLD/WAVE%/S5___IND.DTA \
 $(RAW)/HOUSEHOLD/WAVE%/S6___IND.DTA $(RAW)/HOUSEHOLD/WAVE%/S9___IND.DTA \
 $(RAW)/HOUSEHOLD/WAVE%/S10__IND.DTA 
	cd $(COD); stata-se -b -q crIndividual_waves.do    

$(DAT)/household_wave%.dta: $(COD)/crHousehold_waves.do $(RAW)/HOUSEHOLD/WAVE%/S11A_OTH.DTA \
 $(RAW)/HOUSEHOLD/WAVE%/S11B_OTH.DTA $(RAW)/HOUSEHOLD/WAVE%/S11G_DUR.DTA \
 $(RAW)/HOUSEHOLD/WAVE%/S12A_OTH.DTA $(RAW)/HOUSEHOLD/WAVE%/S14D_DUR.DTA \
 $(RAW)/HOUSEHOLD/WAVE%/S15A_DUR.DTA $(RAW)/HOUSEHOLD/WAVE%/S16A_DUR.DTA \
 $(RAW)/HOUSEHOLD/WAVE%/S19C_IND.DTA $(RAW)/HOUSEHOLD/WAVE%/S1___IND.DTA 
	cd $(COD); stata-se -b -q crHousehold_waves.do    

    

# Descriptive statistics
	
# Analysis files	

# Clean directories for (most) generated files
# This does not clean generated data files; mainly because I am a chicken
.PHONY: cleanall cleanfig cleantex cleancode
cleanall: cleanfig cleantex cleancode
	cd $(DAT); rm *.ster
	cd $(TAB); rm *.tex
	
cleanfig:
	cd $(FIG); rm *.eps
	
cleantex:
	cd $(TEX); rm *.aux; rm *.bbl; rm *.blg; rm *.log; rm *.out; rm *.pdf; rm *.gz
	
cleancode:	
	cd $(COD); rm *.log
	