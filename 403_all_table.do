
*================================================================
** SETUP
clear all
set more off
capture log close


** Directory (change accordingly)
use "/Users/keyifan/Library/Mobile Documents/com~apple~CloudDocs/UofT/24Winter/ECO403/403_Data/ReplicationDatasets/dataset_cross_clean.dta"

cd "/Users/keyifan/Library/Mobile Documents/com~apple~CloudDocs/UofT/24Winter/ECO403/403_Data/output"



***cleaning 
*** table about the age group cohort 


*early treated group and late treated group - > Anna multiple group and periods DID

** age cohort and school attention 

** Globals for boottest
global reps=5000
global seed=3005



drop if birth_year == .
gen upe_cohort = .
replace upe_cohort = 1 if birth_year>=1973 & birth_year<=1980
replace upe_cohort = 0 if upe_cohort == . 



global controls urban_wardnomiss   pcabadhousenomiss   mprimaryedunomiss    msechigheredunomiss  fprimaryedunomiss fsechigheredunomiss  

** Labels for tables
lab var urban_wardnomiss "Urban"
lab var pcabadhousenomiss "Bad House (PCA)"
lab var mprimaryedunomiss "Mother Primary Edu"
lab var msechigheredunomiss "Mother Secondary Edu and above"
lab var fprimaryedunomiss "Father Primary Edu"
lab var fsechigheredunomiss "Father Secondary Edu and above"
lab var upe_cohort "UPE Policy Affected Cohorts"
lab var birth_year "Year of Birth"
lab var brideprice_pmt "Bride Price Payment Amount"
lab var marriageb18 "Married Under 18"


save "used_data.dta"

***Table 1 Summary Statistics 


local panel_A $controls upe_cohort birth_year cluster_grid marriageb18 brideprice_pmt

estpost tabstat `panel_A' if female == 1, stat(N mean sd min max) col(stat)	
eststo sumstats_girl	
estpost tabstat `panel_A' if female == 0, stat(N mean sd min max) col(stat)	
eststo sumstats_boy	
estpost tabstat `panel_A', stat(N mean sd min max) col(stat)	
eststo sumstats_all

* Table 1: SS by gender
esttab sumstats_girl sumstats_boy using "table1ss.tex", replace ///
    cells("count mean(fmt(2)) sd(fmt(2)) min max") ///
	mtitle("Female" "Male") ///
    nonumber label collabels("N" "Mean" "SD" "Min" "Max") ///
    title(" Summary Statistics By Gender") ///
    varwidth(20) compress booktabs




*** Table 2: Illustrate the Cohort's child marriage conditions

// Generate Table for OLS female and male upe_cohort marriageb18

foreach i in marriageb18 {
*col. 1 
    reg `i' upe_cohort i.birth_year i.cluster_grid if female==1, robust cluster(cluster_grid)
    eststo female_t1
    sum `i' if e(sample)
    estadd scalar mean_out=round(r(mean), 0.01)
    estadd local ages "0-18"
    boottest upe_cohort=0, cluster(cluster_grid) small noci nograph seed($seeds) boottype(wild)
    estadd scalar pval_boot=r(p)
	quietly estadd local birth_year_fe "Yes", replace
	quietly estadd local ctrl "No", replace
*Col.2
	reg `i' upe_cohort $controls i.birth_year i.cluster_grid if female==1, robust cluster(cluster_grid)
    eststo female_t2
    sum `i' if e(sample)
    estadd scalar mean_out=round(r(mean), 0.01)
    estadd local ages "0-18"
    boottest upe_cohort=0, cluster(cluster_grid) small noci nograph seed($seeds) boottype(wild)
    estadd scalar pval_boot=r(p)
	quietly estadd local birth_year_fe "Yes", replace
	quietly estadd local ctrl "Yes", replace
}

	
foreach i in marriageb18 {
*col. 1 
    reg `i' upe_cohort i.birth_year i.cluster_grid if female== 0 , robust cluster(cluster_grid)
    eststo male_t1
    sum `i' if e(sample)
    estadd scalar mean_out=round(r(mean), 0.01)
    estadd local ages "0-18"
    boottest upe_cohort=0, cluster(cluster_grid) small noci nograph seed($seeds) boottype(wild)
    estadd scalar pval_boot=r(p)
	quietly estadd local birth_year_fe "Yes", replace
	quietly estadd local ctrl "No", replace
*Col.2
	reg `i' upe_cohort $controls i.birth_year i.cluster_grid if female== 0, robust cluster(cluster_grid)
    eststo male_t2
    sum `i' if e(sample)
    estadd scalar mean_out=round(r(mean), 0.01)
    estadd local ages "0-18"
    boottest upe_cohort=0, cluster(cluster_grid) small noci nograph seed($seeds) boottype(wild)
    estadd scalar pval_boot=r(p)
	quietly estadd local birth_year_fe "Yes", replace
	quietly estadd local ctrl "Yes", replace
}


** Export table
#delimit ;
esttab female_t1 female_t2 male_t1 male_t2
using "tab_upe_marriage.tex",
replace style(tex) collabels(none)
label ml(none) keep(upe_cohort $controls)
cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) pval_boot(par(\[ \]) fmt(%9.3f)))
starlevels(* 0.1 ** 0.05 *** 0.01)
stats(mean_out r2 N birth_year_fe ctrl, fmt(3 3 0) label("Mean Dependent Variable" "R$^2$" "Observations" "Birth Year Fixed Effects" "Controls" ))
;
#delimit cr





//  Table 3 for education & upe

foreach i in primaryedu {
*col. 1 
    reg `i' upe_cohort i.birth_year i.cluster_grid if female==1, robust cluster(cluster_grid)
    eststo female_e1
    sum `i' if e(sample)
    estadd scalar mean_out=round(r(mean), 0.01)
    estadd local ages "0-18"
    boottest upe_cohort=0, cluster(cluster_grid) small noci nograph seed($seeds) boottype(wild)
    estadd scalar pval_boot=r(p)
	quietly estadd local birth_year_fe "Yes", replace
	quietly estadd local ctrl "No", replace
*Col.2
	reg `i' upe_cohort $controls i.birth_year i.cluster_grid if female==1, robust cluster(cluster_grid)
    eststo female_e2
    sum `i' if e(sample)
    estadd scalar mean_out=round(r(mean), 0.01)
    estadd local ages "0-18"
    boottest upe_cohort=0, cluster(cluster_grid) small noci nograph seed($seeds) boottype(wild)
    estadd scalar pval_boot=r(p)
	quietly estadd local birth_year_fe "Yes", replace
	quietly estadd local ctrl "Yes", replace
}

	
foreach i in primaryedu {
*col. 1 
    reg `i' upe_cohort i.birth_year i.cluster_grid if female== 0 , robust cluster(cluster_grid)
    eststo male_e1
    sum `i' if e(sample)
    estadd scalar mean_out=round(r(mean), 0.01)
    estadd local ages "0-18"
    boottest upe_cohort=0, cluster(cluster_grid) small noci nograph seed($seeds) boottype(wild)
    estadd scalar pval_boot=r(p)
	quietly estadd local birth_year_fe "Yes", replace
	quietly estadd local ctrl "No", replace
*Col.2
	reg `i' upe_cohort $controls i.birth_year i.cluster_grid if female== 0, robust cluster(cluster_grid)
    eststo male_e2
    sum `i' if e(sample)
    estadd scalar mean_out=round(r(mean), 0.01)
    estadd local ages "0-18"
    boottest upe_cohort=0, cluster(cluster_grid) small noci nograph seed($seeds) boottype(wild)
    estadd scalar pval_boot=r(p)
	quietly estadd local birth_year_fe "Yes", replace
	quietly estadd local ctrl "Yes", replace
}

** Export table
#delimit ;
esttab female_e1 female_e2 male_e1 male_e2
using "tab_edu_upe.tex",
replace style(tex) collabels(none)
label ml(none) keep(upe_cohort $controls)
cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) pval_boot(par(\[ \]) fmt(%9.3f)))
starlevels(* 0.1 ** 0.05 *** 0.01)
stats(mean_out r2 N birth_year_fe ctrl, fmt(3 3 0) label("Mean Dependent Variable" "R$^2$" "Observations" "Birth Year Fixed Effects" "Controls" ))
;
#delimit cr


//	Table 4: Generate OLS edu on child marriage

*ols model
reg marriageb18 primaryedu i.birth_year i.cluster_grid if female==1, robust cluster(cluster_grid)
eststo main_ols_1
estadd scalar mean_out=round(r(mean), 0.01)
boottest upe_cohort=0, cluster(cluster_grid) small noci nograph seed($seeds) boottype(wild)
estadd scalar pval_boot=r(p)
quietly estadd local birth_year_fe "Yes", replace
quietly estadd local ctrl "No", replace


*with control
reg marriageb18 primaryedu $controls i.birth_year i.cluster_grid if female==1, robust cluster(cluster_grid)
eststo main_ols_2
estadd scalar mean_out=round(r(mean), 0.01)
boottest upe_cohort=0, cluster(cluster_grid) small noci nograph seed($seeds) boottype(wild)
estadd scalar pval_boot=r(p)
quietly estadd local birth_year_fe "Yes", replace
quietly estadd local ctrl "Yes", replace


*2sls

ivregress 2sls marriageb18 (primaryedu = upe_cohort) i.cluster_grid if female==1 , robust cluster(cluster_grid)
eststo main_iv_1
estat firststage
* add manually the F-test
quietly estadd local ftest "5.20", replace 
quietly estadd local birth_year_fe "No", replace
quietly estadd local ctrl "No", replace

*2sls model 2

ivregress 2sls marriageb18 (primaryedu = upe_cohort) $controls i.cluster_grid if female==1 , robust cluster(cluster_grid)
eststo main_iv_2
estat firststage
quietly estadd local ftest "5.24", replace 
quietly estadd local birth_year_fe "No", replace
quietly estadd local ctrl "Yes", replace



/* examine the instruments*** 

* the first stage alone

reg primaryedu upe_cohort $controls i.birth_year i.cluster_grid if female==1, robust cluster(cluster_grid)

* test F-stat
test upe_cohort

* 150ish, very robust
* dropped missing marriageb18 -> 12

reg primaryedu upe_cohort $controls age i.cluster_grid if female==1, robust cluster(cluster_grid)

* test F-stat
test upe_cohort
* 210 
* dropped missing marriageb18 -> 2.39

reg brideprice_pmt upe_cohort $controls i.birth_year i.cluster_grid if female==1, robust cluster(cluster_grid)

test upe_cohort

* 48.26

reg brideprice_pmt upe_cohort $controls age i.cluster_grid if female==1, robust cluster(cluster_grid)

test upe_cohort

* F-test 0.1 so bad


* problem address: de-mean?? dummy excluding 73 - 80 birth year?

*/


// Create the table
esttab main_ols_1 main_ols_2 main_iv_1 main_iv_2  ///
    using "main1.tex", replace ///
    label booktabs nocons nodepvars nonumbers ///
    mtitles("(1)" "(2)" "(3)" "(4)") ///
    mgroups("OLS" "2SLS", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
    alignment(D{.}{.}{-1}) ///
     title("Educations's Impact on Child Marriages") ///
    keep(primaryedu upe_cohort   $controls) ///
    order(primaryedu upe_cohort   $controls) ///
	se star(* 0.10 ** 0.05 *** 0.01) ///
    stats(ftest N r2 birth_year_fe ctrl, fmt(2 %9.0fc %9.3f) labels("First-stage F-test" "Observations" "R-squared Overall" "Birth Year Fixed Effects" "Controls" )) 
	

	
** Table 5
reg brideprice_pmt upe_cohort i.birth_year i.cluster_grid if female==1, robust cluster(cluster_grid)
eststo bp_upe_1
quietly estadd local ftest "5.24", replace 
quietly estadd local birth_year_fe "Yes", replace
quietly estadd local ctrl "No", replace

reg brideprice_pmt upe_cohort $controls i.birth_year i.cluster_grid if female==1, robust cluster(cluster_grid)
eststo bp_upe_2
quietly estadd local ftest "5.24", replace 
quietly estadd local birth_year_fe "Yes", replace
quietly estadd local ctrl "Yes", replace


** Export table
#delimit ;
esttab bp_upe_1 bp_upe_2
using "tab_bp_upe.tex",
title ("UPE and Bride Prices") 
replace style(tex) collabels(none)
label ml(none) keep(upe_cohort $controls)
cells(b(star fmt(%9.3f)) se(par fmt(%9.3f)) pval_boot(par(\[ \]) fmt(%9.3f)))
starlevels(* 0.1 ** 0.05 *** 0.01)
stats(mean_out r2 N birth_year_fe ctrl, fmt(3 3 0) label("Mean Dependent Variable" "R$^2$" "Observations" "Birth Year Fixed Effects" "Controls" ))
;
#delimit cr



//	Table 6: Generate OLS &2SLS edu on Bride Price

*ols model
reg brideprice_pmt primaryedu i.birth_year i.cluster_grid if female==1, robust cluster(cluster_grid)
eststo bp_ols_1
estadd scalar mean_out=round(r(mean), 0.01)
boottest upe_cohort=0, cluster(cluster_grid) small noci nograph seed($seeds) boottype(wild)
estadd scalar pval_boot=r(p)
quietly estadd local birth_year_fe "Yes", replace
quietly estadd local ctrl "No", replace


*with control
reg brideprice_pmt primaryedu $controls i.birth_year i.cluster_grid if female==1, robust cluster(cluster_grid)
eststo bp_ols_2
estadd scalar mean_out=round(r(mean), 0.01)
boottest upe_cohort=0, cluster(cluster_grid) small noci nograph seed($seeds) boottype(wild)
estadd scalar pval_boot=r(p)
quietly estadd local birth_year_fe "Yes", replace
quietly estadd local ctrl "Yes", replace


*2sls

ivregress 2sls brideprice_pmt (primaryedu = upe_cohort) i.cluster_grid if female==1 , robust cluster(cluster_grid)
eststo bp_iv_1
estat firststage
* add manually the F-test
quietly estadd local ftest "5.51", replace 
quietly estadd local birth_year_fe "No", replace
quietly estadd local ctrl "No", replace

*2sls model 2

ivregress 2sls brideprice_pmt (primaryedu = upe_cohort) $controls i.cluster_grid if female==1 , robust cluster(cluster_grid)
eststo bp_iv_2
estat firststage
quietly estadd local ftest "5.20", replace 
quietly estadd local birth_year_fe "No", replace
quietly estadd local ctrl "Yes", replace




// Create the table
esttab bp_ols_1 bp_ols_2 bp_iv_1 bp_iv_2  ///
    using "main2.tex", replace ///
    label booktabs nocons nodepvars nonumbers ///
    mtitles("(1)" "(2)" "(3)" "(4)") ///
    mgroups("OLS" "2SLS", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
    alignment(D{.}{.}{-1}) ///
     title("Educations's Impact on Bride Price") ///
    keep(primaryedu upe_cohort   $controls) ///
    order(primaryedu upe_cohort   $controls) ///
	se star(* 0.10 ** 0.05 *** 0.01) ///
    stats(ftest N r2 birth_year_fe ctrl, fmt(2 %9.0fc %9.3f) labels("First-stage F-test" "Observations" "R-squared Overall" "Birth Year Fixed Effects" "Controls" )) 
	
	