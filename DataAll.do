*Reshaping & Merging of the datasets*

*HDI data*
reshape long y, i(country) j(HDI)
rename y hdi
rename HDI year

*HH Export Diversification*
reshape long y, i(country) j(Export1)
rename y export1
rename Export1 year
generate export2 = real(export1)
drop export1
rename concentrate EXPORT

*GDP per capita, PPP (constant 2011 $ international)*
reshape long y, i(country) j(GDPcap)
rename y gdpcap
rename GDPcap year

*Rule of Law*
reshape long Y, i(Country) j(LAW)
rename Y law
rename LAW year
encode law, generate (law1)

*% of Trade as GDP%
reshape long y, i(country) j(Trade)
rename y trade
rename Trade year

*Merging of data*

*HDI and Export*
merge m:m country year using "/Users/AnnElizabeth/Documents/Grad School/Advanced Trade/DATA2/HH Product Concentration/export.dta"
drop _merge

*Merging HDI/Export & GDP per capita*
merge m:m country year using "/Users/AnnElizabeth/Documents/Grad School/Advanced Trade/DATA2/GDP per capita (PPP, constant)/GPD per cap.dta"
drop _merge

*Merging HDI/Export/GDPcap & Rule of Law*
merge m:m country year using "/Users/AnnElizabeth/Documents/Grad School/Advanced Trade/DATA2/Rule of Law/Rule of Law.dta"
drop _merge

*Merging HDI/Export/GDPcap/Rule of Law & Trade % of GDP*
merge m:m country year using "/Users/AnnElizabeth/Documents/Grad School/Advanced Trade/DATA2/HH Product Concentration/Concentrate.dta"
drop _merge

*Making sure that all variables are represented as integers, not strings*
generate export2 = real(export)
generate law2 = real(law)
drop export1 law1
drop export law
rename export2 export
rename law2 law
drop country1

*Correcting labels*
rename hdi HDI
rename gdpcap GDPCAP
rename trade TRADE
rename law LAW

*Summary & Exploratory statistics*
summarize hdi gdpcap trade law EXPORT
histogram HDI
histogram GDPCAP
histogram TRADE
histogram LAW
histogram EXPORT

histogram EXPORT if HDI<= .7 
histogram EXPORT if HDI

sort TRADE
sort country year
sort EXPORT
sort LAW
sort HDI
sort GDPCAP

*Lowess/LinePlots*
lowess EXPORT HDI, bwidth (.8)
lowess EXPORT HDI, bwidth (.5)
lowess EXPORT GDPCAP
lowess GDPCAP LAW

lowess EXPORT HDI
lowess EXPORT HDI, noweight
lowess EXPORT HDI, mean
lowess EXPORT HDI, logit
lowess EXPORT HDI, adjust

lowess EXPORT GDPCAP
lowess EXPORT GDPCAP, noweight
lowess EXPORT GDPCAP, bwidth (.3)

lowess export HDI

*Individual country plots -> none are riveting*
 
tw line EXPORT HDI year if country == "Australia"
tw line EXPORT HDI year if country == "Germany"
tw line EXPORT HDI year if country == "Iraq"

 
tw line EXPORT HDI year if country == "Kenya"
tw line EXPORT HDI year if country == "South Africa"
tw line EXPORT HDI year if country == "China"

 
tw line EXPORT HDI year if country == "Malawi"
tw line EXPORT HDI year if country == "Rwanda"
tw line EXPORT HDI year if country == "Myanmar"
tw line EXPORT HDI year if country == "Panama"

tw line EXPORT HDI year if country == "United Arab Emirates"
tw line EXPORT GDPCAP year if country == "Bangladesh"


*Correlation*
corr EXPORT HDI GDPCAP LAW TRADE

*Declaring it as panel data*
xtset country
encode country, gen(ccc)
list country ccc
sort country
list country ccc
list ccc, nolabel
xtset ccc
xtset ccc year, yearly


*HDI^2*
gen HDI2 = HDI^2

*Grabbing summary statistics*
xtsum EXPORT HDI GDPCAP TRADE LAW

*Hausman Test*
xtreg EXPORT HDI GDPCAP TRADE LAW, fe
estimates store fixed
xtreg EXPORT HDI GDPCAP TRADE LAW, re 
estimates store re
hausman fixed re

*Testing for time-fixed effects*
xtreg EXPORT HDI GDPCAP TRADE LAW i.year, fe
testparm i.year

*Testing for serial correlation*
findit xtserial
net install st0039
ssc install xtserial

xtserial EXPORT HDI GDPCAP TRADE LAW

*Testing for heteroskedastcity*
ssc install xttest3
xttest3

*Panel Data Regression - Linear*
xtreg EXPORT HDI GDPCAP, fe robust
predict yhat
tw scatter yhat HDI 
lowess yhat TRADE, bwidth (.5)
tw line yhat EXPORT year if country == "United States"

*Panel Data Regression - Quadratic*
xtreg EXPORT HDI HDI2 GDPCAP, fe robust
predict yhat1
tw scatter yhat1 GDPCAP

drop GDPCAP2
generate GDPCAP2 = GDPCAP^2

xtreg EXPORT HDI GDPCAP TRADE LAW i.year, fe 
xtreg EXPORT HDI HDI2 GDPCAP, fe robust 
xtreg EXPORT HDI2 GDPCAP, fe robust 

xtreg EXPORT HDI GDPCAP TRADE LAW, fe vce(robust)
predict yy 
predict r, resid

lowess r yy
xtreg EXPORT HDI HDI2 GDPCAP TRADE LAW i.year, fe

*Prediction*
drop yhat
xtreg EXPORT HDI GDPCAP TRADE LAW, fe robust
predict yhat
lowess yhat HDI
lowess yhat HDI, bwidth (.5)

