tab N
drop N O P Q R S T U V W X Y Z
rename Name name
rename DOB dob
gen name_clean = lower(name)
replace name_clean = proper(name_clean)
label variable name_clean "Respondent Name (in sentence case)"
destring dob, replace
des dob
list dob in 1/5
format dob %td
des dob
format dob %tdDD/NN/CCYY
tab dob
list dob in 1/5
label variable dob "Date of Birth (DD/MM/YYYY)"
gen ref_date = td(01jan2023)
format ref_date %tdDD/NN/CCYY
tab ref_date
gen age = int((ref_date - dob)/365)
sum age
list age in 1/5
drop if missing(dob)
sum dob
replace age = int((ref_date - dob)/365.25)
list age in 1/5
gen age_cat = .
replace age_cat = 1 if age < 25
replace age_cat = 2 if age >= 25 & age <35
replace age_cat = 3 if age >= 35 & age <45
replace age_cat = 4 if age >= 45
label define age_lbl 1 "<25" 2 "25-34" 3 "35-44" 4 "45+"
label values age_cat age_lbl
tab age_cat
tab age_cat, col
graph bar, over(age_cat) title("Age Distribution of Recipients")
graph save "Graph" "F:\Internship\Samhita\Age Graph.gph"
label variable ref_date "Reference Date (01 Jan 2023)"
label variable age "Age of Recipient (in years)"
label variable age_cat "Age Category of Recipient"
codebook age_cat
describe Caste City
replace City  = proper(lower(trim(City)))
replace Caste = upper(trim(Caste))
tab1 Caste City
replace Caste = "GENERAL" if inlist(Caste, "GENERAAL", "GENERALL")
replace Caste = "OBC" if Caste == "OBCC"
replace Caste = "SC" if Caste == "SCC"
replace Caste = "ST" if Caste == "STT"
tab Caste
fre Caste
tab City Caste, row
tab City Caste, row nocol
bysort City: gen city_n = _N
tab City Caste if city_n >= 5, row
tab City Caste, row col
tab city_n
tab City Caste if city_n >= 5, row
save profile_clean.dta, replace
des
drop M N O P Q R S T U V W X Y Z
drop if missing(Lastmonthfamilyincome)
des
rename UniqueId Unique_Id
rename Lossinbusines~d     loss_covid
rename Changesinbusi~d     change_covid
rename LastmonthIndi~e     ind_income_bl
rename Lastmonthfami~e     fam_income_bl
rename FinancialTrai~g     fin_training
rename Doyouhaveanyp~s     any_borrowing
rename Haveyourepaid~i     repaid_borrowing
rename SavingFrequen~y     saving_freq
rename Forseework          foresee_work
des
foreach var of varlist * {
    if "`var'" != "Unique_Id" {
        rename `var' bl_`var'
    }
}
des
rename bl_ind_income~1 bl_ind_income
rename bl_ind_income_bl bl_ind_income
rename bl_fam_income_bl bl_fam_income
des
duplicates report Unique_Id
save baseline_clean.dta, replace
drop L M N O P Q R S T U W V X Y Z
drop if missing(Lastmonthfamilyincome)
rename UniqueId Unique_Id
foreach var of varlist * {
    if "`var'" != "Unique_Id" {
        rename `var' el_`var'
    }
}
des
rename el_Lastmonthfamilyincome     el_fam_income
rename el_ReturnableGrantamountgiven el_grant_amount
rename el_Grantamountspent          el_grant_spent
rename el_Financialtraining         el_fin_training
rename el_Savings                   el_savings
rename el_SavingFrequency           el_saving_freq
rename el_Forseework                el_foresee_work
rename el_LastmonthIndividualIncome el_ind_income
rename el_repaymentsupporttakentorepay el_repayment_support
des
duplicates report Unique_Id
des
save endline_clean.dta, replace
clear
use baseline_clean.dta, clear
graph bar (count), over(bl_loss_covid) title("Impact of Covid on Businesses") ytitle("Number of Recipients") blabel(bar)
graph save "Graph" "F:\Internship\Samhita\Impact of Covid.gph"
graph use "F:\Internship\Samhita\Impact of Covid.gph"
tab bl_loss_covid
list bl_loss_covid in 1/20
use profile_clean.dta, clear
duplicates report UniqueId
rename UniqueId Unique_Id
duplicates report Unique_Id
merge 1:1 Unique_Id using baseline_clean.dta
tab _merge
drop _merge
merge 1:1 Unique_Id using endline_clean.dta
tab _merge
drop city_n
drop _merge
des
drop bl_Name el_Name
drop name_clean
describe name*
save final_data.dta, replace
summarize el_ind_income Earningmembers el_grant_amount
pwcorr el_ind_income Earningmembers el_grant_amount, sig
reg el_ind_income Earningmembers el_grant_amount
twoway (scatter el_ind_income Earningmembers) (lfit el_ind_income Earningmembers), title("Income vs Earning Members") ytitle("Endline Individual Income") xtitle("Number of Earning Members")
graph save "Graph" "F:\Internship\Samhita\income vs earning member.gph"
twoway (scatter el_ind_income Earningmembers, jitter(2)) (lfit el_ind_income Earningmembers), title("Income vs Earning Member") ytitle("Endline Individual Income") xtitle("Number of Earning Members")
twoway (scatter el_ind_income Earningmembers, jitter(2)) (lfit el_ind_income Earningmembers), title("Income vs Earning Members") ytitle("Endline Individual Income") xtitle("Number of Earning Members")
graph save "Graph" "F:\Internship\Samhita\income vs earning member graph 2.gph"
graph use "F:\Internship\Samhita\income vs earning member.gph"
tab OccupationTrade
list OccupationTrade in 1/5
replace OccupationTrade = proper(lower(trim(OccupationTrade)))
* Tailor group
replace OccupationTrade = "Tailor" if inlist(OccupationTrade, "Tailoring", "Tailorr", "Tailorrr", "Silai Bunai")
* Vegetable sellers
replace OccupationTrade = "Vegetable Seller" if inlist(OccupationTrade, "Vegetable", "Vegeatble", "Vegetable Seller")
* Agriculture
replace OccupationTrade = "Agriculture" if inlist(OccupationTrade, "Kheti")
* Fish sellers
replace OccupationTrade = "Fish Seller" if inlist(OccupationTrade, "Fish")
* Beauty related
replace OccupationTrade = "Beauty Parlor" if inlist(OccupationTrade, "Parlour", "Makeup")
* Grocery
replace OccupationTrade = "Grocery Store" if inlist(OccupationTrade, "Parchun")
* Dairy
replace OccupationTrade = "Dairy" if inlist(OccupationTrade, "Milk")
* Food vendors
replace OccupationTrade = "Food Vendor" if inlist(OccupationTrade, "Vadapao Seller", "Paobhaji Seller", "Bhaji")
* General shop
replace OccupationTrade = "Shop" if inlist(OccupationTrade, "Shop", "Garment Shop")
tab OccupationTrade
replace OccupationTrade = "Imitation Work" if OccupationTrade == "Emitation Work"
replace OccupationTrade = "Home Tiffin Service" if OccupationTrade == "Home Tiffine Service"
replace OccupationTrade = "Online Product Business" if OccupationTrade == "Online Produced Buissnes"
tab OccupationTrade
replace OccupationTrade = "Service" if inlist(OccupationTrade, "Anganwadi", "Riksha & Dabeli Shop", "Home Tiffin Service")
replace OccupationTrade = "Small Business" if inlist(OccupationTrade, "Cosmetic Seller", "Hair Accessories Seller", "Shop", "Online Product Business")
replace OccupationTrade = "Food Business" if inlist(OccupationTrade, "Food Vendor", "Hotel", "Canteen")
replace OccupationTrade = "Manufacturing" if inlist(OccupationTrade, "Flour Mill", "Pulse Mill", "Imitation Work")
tab OccupationTrade
replace OccupationTrade = "Agriculture" if OccupationTrade == "Poultry"
tab OccupationTrade
gen bl_income_cat = .
replace bl_income_cat = 1 if bl_ind_income <= 5000
replace bl_income_cat = 2 if bl_ind_income > 5000 & bl_ind_income <= 10000
replace bl_income_cat = 3 if bl_ind_income > 10000 & bl_ind_income <= 15000
replace bl_income_cat = 4 if bl_ind_income > 15000
label define income_lbl 1 "Low (<=5k)" 2 "Lower-Mid (5k–10k)" 3 "Upper-Mid (10k–15k)" 4 "High (>15k)"
label values bl_income_cat income_lbl
tab bl_income_cat
gen el_income_cat = .
replace el_income_cat = 1 if el_ind_income <= 5000
replace el_income_cat = 2 if el_ind_income > 5000 & el_ind_income <= 10000
replace el_income_cat = 3 if el_ind_income > 10000 & el_ind_income <= 15000
replace el_income_cat = 4 if el_ind_income > 15000
label values el_income_cat income_lbl
tab el_income_cat
gen income_change = el_ind_income - bl_ind_income
fre income_change
tab income_change
gen change_cat = .
replace change_cat = 1 if income_change < 0
replace change_cat = 2 if income_change == 0
replace change_cat = 3 if income_change > 0
label define change_lbl 1 "Decreased" 2 "No Change" 3 "Increased"
label values change_cat change_lbl
tab change_cat
tab OccupationTrade bl_income_cat, row
tab OccupationTrade el_income_cat, row
tab OccupationTrade change_cat, row
summarize bl_ind_income el_ind_income
tab OccupationTrade change_cat, row
gen pct_change_ind = ((el_ind_income - bl_ind_income) / bl_ind_income) * 100
tab pct_change_ind
gen pct_change_fam = ((el_fam_income - bl_fam_income) / bl_fam_income) * 100
replace pct_change_ind = . if bl_ind_income == 0
replace pct_change_fam = . if bl_fam_income == 0
tab pct_change_fam
tab pct_change_ind
summarize pct_change_ind pct_change_fam
tab pct_change_fam
summarize pct_change_ind, detail
tab bl_saving_freq
tab el_saving_freq
tab bl_Savings
tab el_savings
replace bl_saving_freq = proper(lower(trim(bl_saving_freq)))
replace el_saving_freq = proper(lower(trim(el_saving_freq)))
replace bl_Savings = proper(lower(trim(bl_Savings)))
tab bl_Savings
replace el_savings = proper(lower(trim(el_savings)))
tab el_savings
encode bl_saving_freq, gen(bl_freq_num)
encode el_saving_freq, gen(el_freq_num)
encode bl_Savings, gen(bl_save_num)
encode el_savings, gen(el_save_num)
tab bl_Savings
tab bl_save_num
tab bl_saving_freq el_saving_freq, row
tab bl_Savings el_savings, row
gen freq_change = el_freq_num - bl_freq_num
gen freq_cat = .
replace freq_cat = 1 if freq_change < 0
replace freq_cat = 2 if freq_change == 0
replace freq_cat = 3 if freq_change > 0
label values freq_cat freq_lbl
tab freq_cat
label define freq_lbl 1 "Decreased Saving Frequency" 2 "No Change" 3 "Increased Saving Frequency"
label values freq_cat freq_lbl
tab freq_cat
graph bar (count), over(freq_cat) title("Change in Saving Behavior (Baseline vs Endline)") ytitle("Number of Recipients") blabel(bar)
graph save "Graph" "F:\Internship\Samhita\Change in Saving Behaviour.gph"
gen bl_freq_ord = .
replace bl_freq_ord = 1 if bl_saving_freq == "About Once A Month"
replace bl_freq_ord = 2 if bl_saving_freq == "Weekly"
replace bl_freq_ord = 3 if bl_saving_freq == "Daily"
tab bl_freq_ord
gen el_freq_ord = .
replace el_freq_ord = 1 if el_saving_freq == "About Once A Month"
replace el_freq_ord = 2 if el_saving_freq == "Weekly"
replace el_freq_ord = 3 if el_saving_freq == "Daily"
tab el_freq_ord
replace freq_cat = 1 if freq_change < 0
replace freq_cat = 2 if freq_change == 0
replace freq_cat = 3 if freq_change > 0
label values freq_cat freq_lbl
tab freq_cat
tab bl_saving_freq
tab el_saving_freq
gen bl_freq_simple = .
replace bl_freq_simple = 1 if strpos(bl_saving_freq, "Month")
replace bl_freq_simple = 2 if strpos(bl_saving_freq, "Week")
replace bl_freq_simple = 3 if strpos(bl_saving_freq, "Daily") | strpos(bl_saving_freq, "Consecutive")
gen el_freq_simple = .
replace el_freq_simple = 1 if strpos(el_saving_freq, "Month")
replace el_freq_simple = 2 if strpos(el_saving_freq, "Week")
replace el_freq_simple = 3 if strpos(el_saving_freq, "Daily") | strpos(el_saving_freq, "Consecutive")
tab el_freq_ord bl_freq_ord
tab1 el_freq_ord bl_freq_ord
replace freq_cat = 1 if freq_change < 0
replace freq_cat = 2 if freq_change == 0
replace freq_cat = 3 if freq_change > 0
tab freq_cat
gen valid = !missing(bl_freq_ord) & !missing(el_freq_ord)
tab valid
gen freq_change_clean = el_freq_ord - bl_freq_ord if valid==1
gen freq_cat_clean = .
replace freq_cat_clean = 1 if freq_change_clean < 0
replace freq_cat_clean = 2 if freq_change_clean == 0
replace freq_cat_clean = 3 if freq_change_clean > 0
label values freq_cat_clean freq_lbl
tab freq_cat_clean
drop freq_change_clean freq_cat_clean
gen freq_change_clean = .
replace freq_change_clean = el_freq_ord - bl_freq_ord if valid==1
gen freq_cat_clean = .
replace freq_cat_clean = 1 if freq_change_clean < 0 & valid==1
replace freq_cat_clean = 2 if freq_change_clean == 0 & valid==1
replace freq_cat_clean = 3 if freq_change_clean > 0 & valid==1
label values freq_cat_clean freq_lbl
tab1 freq_change_clean freq_cat_clean
tab freq_cat_clean if valid==1
tab valid
tab freq_cat_clean if valid==2
sum valid
des valid
save "final_data.dta", replace
des
drop bl_freq_num el_freq_num bl_save_num el_save_num
drop freq_change freq_cat
drop bl_freq_simple el_freq_simple
drop freq_change_c~n
save final_clean.dta, replace
tab bl_loss_covid
tab age_cat
tab City Caste, row
replace City = proper(lower(trim(City)))
replace City = "Vasai" if inlist(City, "Vasa", "Vasaai", "Vasaii", "Vasaiii")
replace City = "Nalasopara" if inlist(City, "Nalsopra", "Nalsopraa")
replace City = "Virar" if inlist(City, "Virarr")
tab City Caste, row
replace City = "Other" if inlist(City, "Aadane","Gaas","Karnzon","Tambadipada","Vadwali","Sandor")
tab City Caste, row
tab change_cat
tab OccupationTrade change_cat, row
summarize pct_change_ind pct_change_fam
tab freq_cat_clean if valid==1
des
label var pct_change_ind "Percent change in individual income"
label var pct_change_fam "Percent change in family income"
label var freq_cat_clean "Change in saving frequency (clean, matched)"
save "final_clean.dta", replace
label var valid "1 = valid matched obs (baseline & endline), 0 = missing"
label var bl_freq_ord "Baseline saving frequency (ordinal)"
label var el_freq_ord "Endline saving frequency (ordinal)"
label var income_change "Change in individual income (endline - baseline)"
save final_clean.dta, replace
label var change_cat "Direction of income change (decrease/no change/increase)"
label var valid "1 = valid matched obs (baseline & endline), 0 = missing in either"
tab age_cat
tab City Caste, row
tab bl_loss_covid
tab change_cat
tab OccupationTrade change_cat, row
summarize pct_change_ind pct_change_fam
tab freq_cat_clean if valid==1
gen log_el_income = log(el_ind_income + 1)
reg log_el_income Earningmembers el_grant_amount, robust
ttest el_ind_income == bl_ind_income
misstable summarize
pwcorr el_ind_income el_grant_amount Earningmembers, sig
save "final_clean.dta", replace
