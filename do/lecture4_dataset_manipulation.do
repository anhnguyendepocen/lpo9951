capture log close                       // closes any logs, should they be open
log using "lecture4_dataset_manipulation.log", replace    // open new log

// NAME: Dataset manipulatin
// FILE: lecture4_dataset_manipulation.do
// AUTH: Will Doyle
// REVS: Benjamin Skinner
// INIT: 9 September 2012
// LAST: 15 August 2015

clear all                               // clear memory
set more off                            // turn off annoying "__more__" feature

// set globals for url data link and local data path
global urldata "http://www.ats.ucla.edu/stat/stata/library/apipop"
global datadir "../data/"

// read web data into memory
use $urldata, clear

// split into three datasets: elementary, middle, and high school

// -1- preserve dataset in memory
// -2- subset to keep only school type that we want
// -3- save new subset dataset
// -4- restore old dataset

// elementary schools
preserve
keep if stype == 1                      
save ${datadir}elem, replace
restore

// high schools
preserve
keep if stype == 2                      
save ${datadir}hs, replace
restore

// middle schools (keep this one in memory so no preserve/restore needed)
keep if stype == 3                      
save ${datadir}middle, replace

// merging via the append command
append using ${datadir}elem   
append using ${datadir}hs

// merging via the merge command
use ${datadir}elem, clear

merge 1:1 snum using ${datadir}hs, gen(_merge_a)
merge 1:1 snum using ${datadir}middle, gen(_merge_b)

// show merge stats for each merge
tab _merge_a
tab _merge_b

// split dataset by variables
use $urldata, clear

preserve
keep snum api00 api99 ell meals         // variable set 1
save ${datadir}api_1, replace
restore
keep snum full emer                     // variable set 2
save ${datadir}api_2, replace

// merging back together (api_2 in memory)
merge 1:1 snum using ${datadir}api_1

// view merge stats
tab _merge

// collapsing data

// reload main dataset, since we didn't preserve it before
use $urldata, clear

// count of unique counties in dataset
unique cnum

// mean of pcttest and mobility within countyr
collapse (mean) pcttest mobility, by (cnum)

// give count of number of observations (should be number of unique counties)
count

// end file
log close                               // close log
exit                                    // exit script
