# Code

## Passage vs wave

One of the quirks of the data set is the difference between passage and wave.
The "User's Guide to the Kagera Health and Development Survey Datasets, Development 
Research Group The World Bank, December 2004" p 11 has the following description:

> Fieldwork was conducted in four distinct time intervals, or passages, that lasted 
  6-7 months each. For example, the first passage of fieldwork took place between 
  September 1991 and May 1992, during which time questionnaires were administered 
  once in all of the households, communities, markets, schools, and health facilities 
  in the sample.

> During each passage, interviewers visited each household twice, completing the first 
  half of the household questionnaire in the first visit and the second half of the 
  questionnaire two weeks later. These two household visits within a given passage 
  are called rounds.

> The wave of the household questionnaire corresponds to the number of times that a 
  given household has been interviewed. There are four distinct household questionnaires 
  labeled as wave 1, wave 2, wave 3, and wave 4. All households interviewed for the 
  first time received a wave 1 questionnaire, those interviewed for the second time 
  received a wave 2 questionnaire, a third time a wave 3 questionnaire, and so forth. 
  When households dropped out mid-survey, they were replaced with new households, which 
  were interviewed for the first time with a wave 1 household questionnaire, 
  irrespective of the passage. Thus, all households received a wave 1 questionnaire 
  during the first passage, as well as those interviewed for the first time in the 
  second and third passage. Likewise, while most households completed a wave 2 
  questionnaire during the second passage, households interviewed for the second time 
  during the third and fourth passages also completed a wave 2 questionnaire.

> Thus, in the case of the household questionnaire, the wave number of the 
  questionnaire does not necessarily correspond to the passage in which the household 
  was interviewed. 5 However, the questionnaires for communities, markets, health 
  facilities, and schools are also labeled by wave, and for them the wave number 
  of the questionnaire corresponds to the passage in which they were administered. 
  The number of questionnaires of each type completed during each passage is summarized 
  in Table II.1. Traditional healers were interviewed only once, during the third passage.
  
Because of this all files that create data are merged based on passage.

## Create data set for analysis

There are three main files for creating the base data set used for the analysis:

- crHousehold_waves.do: For each of the four waves in the data set this file 
  creates data files with farm area, crop area/loss, durable assets, livestock,
  business assets, buildings, durable goods, and total saving.
  Most of these see minimal processing, except for converting farm areas from hectare
  to acre.
- crIndividual_waves.do: For each of the four waves get basic demographic data, education
  and literacy, health variables, fertility and contraceptive use, and anthropometric
  information.
- crBase.do: Combine all household and individual files. Add partner education and 
  polygyny information, information on leaving the household, and total income 
  calculated by the survey. 
  

These files must be run in order.
This will happen automatically if you use the Makefile described in the main ReadMe.md.

## Analysis files

