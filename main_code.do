

use "/Users/csy/Desktop/finaldata.dta"
merge m:1 county_names cyear cmonth using "//Users/csy/Desktop/AQI_average_months.dta"

//// Data Processing 

gen wave=.
replace wave=2010 if cyear==2010
replace wave=2010 if cyear==2011
replace wave=2014 if cyear==2014
replace wave=2014 if cyear==2015

replace birthyear=. if birthyear<0

gen age=cyear-birthyear //generate Age 

replace hukou=0 if hukou==3 // non-argriculture

replace self_rated_health=. if self_rated_health<0
gen health_status=.
replace health_status=5 if self_rated_health==1
replace health_status=4 if self_rated_health==2
replace health_status=3 if self_rated_health==3
replace health_status=2 if self_rated_health==4
replace health_status=1 if self_rated_health==5

rename smoke smoking

gen marriage=.
replace marriage=0 if single==1
replace marriage=1 if single==0

gen employment=.
replace employment=1 if job==1
replace employment=0 if job==0
replace employment=1 if pg01==1
replace employment=0 if pg01==5


replace cigarettes_pack_per_day=. if cigarettes_pack_per_day<0

destring disease1, generate(Disease1) ignore(`"NA"')
destring disease2, generate(Disease2) ignore(`"NA"')

*** 3 Disease Dummy Variable 
gen disease=1
replace disease=0 if Disease1==-8|Disease1==-2|Disease1==-1|Disease1==999
replace disease=. if Disease1==.

gen  respiratory_disease=0
replace respiratory_disease=1 if Disease1==12.70|  Disease1==12.71|Disease1==12.72|Disease1==12.73|Disease1==12.74|Disease1==12.75|Disease1==12.76|Disease1==12.77|Disease1==12.78|Disease1==3.26
replace respiratory_disease=1 if Disease2==12.70|  Disease2==12.71|Disease2==12.72|Disease2==12.73|Disease2==12.74|Disease2==12.75|Disease2==12.76|Disease2==12.77|Disease2==12.78|Disease2==3.26
replace respiratory_disease=0 if Disease1==-8
replace respiratory_disease=. if Disease1==.

gen heart_disease=0
replace heart_disease=1 if Disease1==11.60|Disease1==11.61|Disease1==11.62|Disease1==11.63|Disease1==11.64|Disease1==11.65
replace heart_disease=1 if Disease2==11.60|Disease2==11.61|Disease2==11.62|Disease2==11.63|Disease2==11.64|Disease2==11.65
replace heart_disease=0 if Disease1==-8
replace heart_disease=. if Disease1==.

gen malignant_tumor=0
replace malignant_tumor=1 if Disease1==3.19|Disease1==3.20|Disease1==3.21|Disease1==3.22|Disease1==3.23|Disease1==3.24|Disease1==3.25|Disease1==3.26|Disease1==3.27|Disease1==3.28|Disease1==3.29|Disease1==3.30
replace malignant_tumor=1 if Disease2==3.19|Disease2==3.20|Disease2==3.21|Disease2==3.22|Disease2==3.23|Disease2==3.24|Disease2==3.25|Disease2==3.26|Disease2==3.27|Disease2==3.28|Disease2==3.29|Disease2==3.30
replace malignant_tumor=0 if Disease1==-8
replace malignant_tumor=. if Disease1==.

save "/Users/csy/Desktop/finaldata.dta", replace 

clear
use "/Users/csy/Desktop/cfps_10and14_AQI_temp.dta"
duplicates drop pid wave, force


//// Change Mental Health Measurement: 0 (never) to 4 (almost every day)
gen monthlyAQI=aqi_mavg/100

replace qq601=. if qq601>5|qq601<0
replace qq602=. if qq602>5|qq602<0
replace qq603=. if qq603>5|qq603<0
replace qq604=. if qq604>5|qq604<0
replace qq605=. if qq605>5|qq605<0
replace qq606=. if qq606>5|qq606<0


gen depressed=.
replace depressed= 0 if qq601==5
replace depressed= 1 if qq601==4
replace depressed= 2 if qq601==3
replace depressed= 3 if qq601==2
replace depressed= 4 if qq601==1

gen nervous=.
replace nervous= 0 if qq602==5
replace nervous= 1 if qq602==4
replace nervous= 2 if qq602==3
replace nervous= 3 if qq602==2
replace nervous= 4 if qq602==1

gen restless=.
replace restless= 0 if qq603==5
replace restless= 1 if qq603==4
replace restless= 2 if qq603==3
replace restless= 3 if qq603==2
replace restless= 4 if qq603==1

gen hopeless=.
replace hopeless= 0 if qq604==5
replace hopeless= 1 if qq604==4
replace hopeless= 2 if qq604==3
replace hopeless= 3 if qq604==2
replace hopeless= 4 if qq604==1

gen difficult=.
replace difficult= 0 if qq605==5
replace difficult= 1 if qq605==4
replace difficult= 2 if qq605==3
replace difficult= 3 if qq605==2
replace difficult= 4 if qq605==1

gen meaningless=.
replace meaningless= 0 if qq606==5
replace meaningless= 1 if qq606==4
replace meaningless= 2 if qq606==3
replace meaningless= 3 if qq606==2
replace meaningless= 4 if qq606==1

egen CES_D =rowtotal(depressed nervous restless hopeless difficult meaningless)


clear
use "/Users/csy/Desktop/finaldata4.21.dta"

///Using physical condition as independent variable, not controlling for smoking disease
   
set more off
xi:reg  health_status  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment  smoking disease i.provcd i.wave  i.cmonth, cluster(provcd)
outreg2 using physical.xls,replace 
 
set more off
xi:reg  health_status  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment   i.provcd i.wave  i.cmonth, cluster(provcd)
outreg2 using physical.xls,append 
 
 
histogram cmonth, discrete width(1) xline(2) legend(col(2)) xtitle("Birth Year and Month")
graph save "/Users/csy/Desktop/graph", replace
graph export "/Users/csy/Desktop/graph.tif", as(tif) replace

 
 /////MonthlyAQI,+ province, month fixed effect 
    
set more off
xi:reg  CES_D  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth, cluster(provcd)
outreg2 using regression.xls,replace 
 
xi:reg  depressed  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth, cluster(provcd)
outreg2 using regression.xls,append

xi:reg  nervous  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth, cluster(provcd)
outreg2 using regression.xls,append
 
xi:reg  restless  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth, cluster(provcd)
outreg2 using regression.xls,append
 
xi:reg  hopeless  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth, cluster(provcd)
outreg2 using regression.xls,append

xi:reg  difficult  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth, cluster(provcd)
outreg2 using regression.xls,append
 
xi:reg  meaningless  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc  employment health_status smoking disease i.provcd i.wave i.cmonth, cluster(provcd)
outreg2 using regression.xls,append
 
 
*** control 3 diseases
    
  set more off
 xi:reg  CES_D  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking respiratory_disease heart_disease malignant_tumor i.provcd i.wave  i.cmonth, cluster(provcd)
 outreg2 using regression12.xls,replace 

  xi:reg  depressed  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking respiratory_disease heart_disease malignant_tumor i.provcd i.wave  i.cmonth, cluster(provcd)
 outreg2 using regression12.xls,append 
 
 xi:reg  nervous  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking respiratory_disease heart_disease malignant_tumor i.provcd i.wave  i.cmonth, cluster(provcd)
 outreg2 using regression12.xls,append 
 
  xi:reg  restless  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking respiratory_disease heart_disease malignant_tumor i.provcd i.wave  i.cmonth, cluster(provcd)
 outreg2 using regression12.xls,append 
 
  xi:reg  hopeless  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking respiratory_disease heart_disease malignant_tumor i.provcd i.wave  i.cmonth, cluster(provcd)
 outreg2 using regression12.xls,append 
 
  xi:reg  difficult  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking respiratory_disease heart_disease malignant_tumor i.provcd i.wave  i.cmonth, cluster(provcd)
 outreg2 using regression12.xls,append 
 
  xi:reg  meaningless  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking respiratory_disease heart_disease malignant_tumor i.provcd i.wave  i.cmonth, cluster(provcd)
 outreg2 using regression12.xls,append 
 
*** AQI: current and past 5 month (只有nervous 0.00566**）
  set more off
 xi:reg  CES_D  aqi_6m_past_avg1  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth, cluster(provcd)
 outreg2 using reg.xls,replace 
 
 xi:reg  depressed  aqi_6m_past_avg1  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth, cluster(provcd)
 outreg2 using reg.xls,append

 xi:reg  nervous  aqi_6m_past_avg1  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth, cluster(provcd)
 outreg2 using reg.xls,append
 
 xi:reg  restless  aqi_6m_past_avg1  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth, cluster(provcd)
 outreg2 using reg.xls,append
 
 xi:reg  hopeless  aqi_6m_past_avg1  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth, cluster(provcd)
 outreg2 using reg.xls,append

 xi:reg  difficult  aqi_6m_past_avg1  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth, cluster(provcd)
 outreg2 using reg.xls,append
 
 xi:reg  meaningless  aqi_6m_past_avg1  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc  employment health_status smoking disease i.provcd i.wave i.cmonth, cluster(provcd)
 outreg2 using reg.xls,append

 
 *** control air quality in Past 3 month
 
 set more off
 xi:reg  CES_D monthlyAQI aqi_3m_past_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth, cluster(provcd)
 outreg2 using past.xls,replace
 
 xi:reg  depressed monthlyAQI aqi_3m_past_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth, cluster(provcd)
 outreg2 using past.xls,append

 xi:reg  nervous monthlyAQI aqi_3m_past_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth, cluster(provcd)
 outreg2 using past.xls,append
 
 xi:reg  restless monthlyAQI aqi_3m_past_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth, cluster(provcd)
 outreg2 using past.xls,append
 
 xi:reg  hopeless monthlyAQI aqi_3m_past_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth, cluster(provcd)
 outreg2 using past.xls,append

 xi:reg  difficult monthlyAQI aqi_3m_past_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth, cluster(provcd)
 outreg2 using past.xls,append
 
 xi:reg  meaningless monthlyAQI aqi_3m_past_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc  employment health_status smoking disease i.provcd i.wave i.cmonth, cluster(provcd)
 outreg2 using past.xls,append
 
 //
 
 set more off
 xi:reg  CES_D monthlyAQI aqi_6m_past_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth, cluster(provcd)
 outreg2 using past.xls,append
 
 xi:reg  depressed monthlyAQI aqi_6m_past_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth, cluster(provcd)
 outreg2 using past.xls,append

 xi:reg  nervous monthlyAQI aqi_6m_past_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth, cluster(provcd)
 outreg2 using past.xls,append
 
 xi:reg  restless monthlyAQI aqi_6m_past_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth, cluster(provcd)
 outreg2 using past.xls,append
 
 xi:reg  hopeless monthlyAQI aqi_6m_past_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth, cluster(provcd)
 outreg2 using past.xls,append

 xi:reg  difficult monthlyAQI aqi_6m_past_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth, cluster(provcd)
 outreg2 using past.xls,append
 
 xi:reg  meaningless monthlyAQI aqi_6m_past_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc  employment health_status smoking disease i.provcd i.wave i.cmonth, cluster(provcd)
 outreg2 using past.xls,append
 
//
 set more off
 xi:reg  CES_D monthlyAQI aqi_12m_past_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth, cluster(provcd)
 outreg2 using past.xls,append
 
 xi:reg  depressed monthlyAQI aqi_12m_past_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth, cluster(provcd)
 outreg2 using past.xls,append

 xi:reg  nervous monthlyAQI aqi_12m_past_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth, cluster(provcd)
 outreg2 using past.xls,append
 
 xi:reg  restless monthlyAQI aqi_12m_past_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth, cluster(provcd)
 outreg2 using past.xls,append
 
 xi:reg  hopeless monthlyAQI aqi_12m_past_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth, cluster(provcd)
 outreg2 using past.xls,append

 xi:reg  difficult monthlyAQI aqi_12m_past_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth, cluster(provcd)
 outreg2 using past.xls,append
 
 xi:reg  meaningless monthlyAQI aqi_12m_past_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc  employment health_status smoking disease i.provcd i.wave i.cmonth, cluster(provcd)
 outreg2 using past.xls,append
 
 
*********** placebo test (future AQI)

 set more off
 xi:reg  CES_D  aqi_6m_future_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth, cluster(provcd)
 outreg2 using future.xls,append
 
 xi:reg  depressed  aqi_6m_future_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth, cluster(provcd)
 outreg2 using future.xls,append

 xi:reg  nervous  aqi_6m_future_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth, cluster(provcd)
 outreg2 using future.xls,append
 
 xi:reg  restless  aqi_6m_future_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth, cluster(provcd)
 outreg2 using future.xls,append
 
 xi:reg  hopeless  aqi_6m_future_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth, cluster(provcd)
 outreg2 using future.xls,append

 xi:reg  difficult  aqi_6m_future_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth, cluster(provcd)
 outreg2 using future.xls,append
 
 xi:reg  meaningless  aqi_6m_future_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc  employment health_status smoking disease i.provcd i.wave i.cmonth, cluster(provcd)
 outreg2 using future.xls,append
 
 /////
  xi:reg  CES_D  aqi_3m_future_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth, cluster(provcd)
 outreg2 using future.xls,append
 
 xi:reg  depressed  aqi_3m_future_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth, cluster(provcd)
 outreg2 using future.xls,append

 xi:reg  nervous  aqi_3m_future_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth, cluster(provcd)
 outreg2 using future.xls,append
 
 xi:reg  restless  aqi_3m_future_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth, cluster(provcd)
 outreg2 using future.xls,append
 
 xi:reg  hopeless  aqi_3m_future_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth, cluster(provcd)
 outreg2 using future.xls,append

 xi:reg  difficult  aqi_3m_future_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth, cluster(provcd)
 outreg2 using future.xls,append
 
 xi:reg  meaningless  aqi_3m_future_avg2  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc  employment health_status smoking disease i.provcd i.wave i.cmonth, cluster(provcd)
 outreg2 using future.xls,append
 
****************************** heterogenous effect

///gender (male=1)

 xi:reg  CES_D  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth if gender==1, cluster(provcd)
 outreg2 using gender.xls,replace 
 

 xi:reg  depressed  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth if gender==1, cluster(provcd)
 outreg2 using gender.xls,append
 
 xi:reg  nervous  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth if gender==1, cluster(provcd) 
 outreg2 using gender.xls,append
 
 xi:reg  restless  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth if gender==1, cluster(provcd)
 outreg2 using gender.xls,append
 
 xi:reg  hopeless  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth if gender==1, cluster(provcd) 
 outreg2 using gender.xls,append

 xi:reg  difficult  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth if gender==1, cluster(provcd) 
 outreg2 using gender.xls,append
 
 xi:reg  meaningless  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth if gender==1, cluster(provcd)
 outreg2 using gender.xls,append
 

///female 

 xi:reg  CES_D  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth if gender==0, cluster(provcd)
 outreg2 using gender.xls, append 
 

 xi:reg  depressed  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth if gender==0, cluster(provcd)
 outreg2 using gender.xls,append
 
 xi:reg  nervous  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth if gender==0, cluster(provcd)
 outreg2 using gender.xls,append
 
 xi:reg  restless  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth if gender==0, cluster(provcd)
 outreg2 using gender.xls,append
 
 xi:reg  hopeless  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth if gender==0, cluster(provcd)
 outreg2 using gender.xls,append

 xi:reg  difficult  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth if gender==0, cluster(provcd)
 outreg2 using gender.xls,append
 
 xi:reg  meaningless  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth if gender==0, cluster(provcd)
 outreg2 using gender.xls,append

///hukou: agricultural ==1
 xi:reg  CES_D  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth if hukou==1, cluster(provcd)
 outreg2 using hukou.xls,replace 
 

 xi:reg  depressed  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth if hukou==1, cluster(provcd)
 outreg2 using hukou.xls,append
 
 xi:reg  nervous  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth if hukou==1, cluster(provcd)
 outreg2 using hukou.xls,append
 
 xi:reg  restless  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth if hukou==1, cluster(provcd)
 outreg2 using hukou.xls,append
 
 xi:reg  hopeless  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth if hukou==1, cluster(provcd)
 outreg2 using hukou.xls,append

 xi:reg  difficult  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth if hukou==1, cluster(provcd)
 outreg2 using hukou.xls,append
 
 xi:reg  meaningless  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth if hukou==1, cluster(provcd)
 outreg2 using hukou.xls,append

//agricultural==0

 xi:reg  CES_D  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth if hukou==0, cluster(provcd)
 outreg2 using hukou.xls,append  
 

 xi:reg  depressed  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth if hukou==0, cluster(provcd)
 outreg2 using hukou.xls,append
 
 xi:reg  nervous  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth if hukou==0, cluster(provcd)
 outreg2 using hukou.xls,append
 
 xi:reg  restless  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth if hukou==0, cluster(provcd)
 outreg2 using hukou.xls,append
 
 xi:reg  hopeless  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth if hukou==0, cluster(provcd)
 outreg2 using hukou.xls,append

 xi:reg  difficult  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth if hukou==0, cluster(provcd)
 outreg2 using hukou.xls,append
 
 xi:reg  meaningless  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth if hukou==0, cluster(provcd)
 outreg2 using hukou.xls,append

 **** employment
 
  xi:reg  CES_D  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc health_status smoking disease i.provcd i.wave  i.cmonth if employment==1, cluster(provcd)
 outreg2 using employment.xls,append  
 

 xi:reg  depressed  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc  health_status smoking disease i.provcd i.wave i.cmonth if employment==1, cluster(provcd)
 outreg2 using employment.xls,append
 
 xi:reg  nervous  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc  health_status smoking disease i.provcd i.wave i.cmonth if employment==1, cluster(provcd)
 outreg2 using employment.xls,append
 
 xi:reg  restless  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc  health_status smoking disease i.provcd i.wave  i.cmonth if employment==1, cluster(provcd)
 outreg2 using employment.xls,append
 
 xi:reg  hopeless  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc  health_status smoking disease i.provcd i.wave i.cmonth if employment==1, cluster(provcd)
 outreg2 using employment.xls,append

 xi:reg  difficult  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc  health_status smoking disease i.provcd i.wave  i.cmonth if employment==1, cluster(provcd)
 outreg2 using employment.xls,append
 
 xi:reg  meaningless  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc  health_status smoking disease i.provcd i.wave i.cmonth if employment==1, cluster(provcd)
 outreg2 using employment.xls,append

//// having no job

 xi:reg  CES_D  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc health_status smoking disease i.provcd i.wave  i.cmonth if employment==0, cluster(provcd)
 outreg2 using employment.xls,append  
 

 xi:reg  depressed  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc  health_status smoking disease i.provcd i.wave i.cmonth if employment==0, cluster(provcd)
 outreg2 using employment.xls,append
 
 xi:reg  nervous  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc  health_status smoking disease i.provcd i.wave i.cmonth if employment==0, cluster(provcd)
 outreg2 using employment.xls,append
 
 xi:reg  restless  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc  health_status smoking disease i.provcd i.wave  i.cmonth if employment==0, cluster(provcd)
 outreg2 using employment.xls,append
 
 xi:reg  hopeless  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc  health_status smoking disease i.provcd i.wave i.cmonth if employment==0, cluster(provcd)
 outreg2 using employment.xls,append

 xi:reg  difficult  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc  health_status smoking disease i.provcd i.wave  i.cmonth if employment==0, cluster(provcd)
 outreg2 using employment.xls,append
 
 xi:reg  meaningless  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc  health_status smoking disease i.provcd i.wave i.cmonth if employment==0, cluster(provcd)
 outreg2 using employment.xls,append
 
 
 ***** disease 
 ///
 xi:reg  CES_D  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking  i.provcd i.wave  i.cmonth if respiratory_disease==1, cluster(provcd)
 outreg2 using subgroup_disease.xls,replace 
 

 xi:reg  depressed  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking  i.provcd i.wave i.cmonth if respiratory_disease==1, cluster(provcd)
 outreg2 using subgroup_disease.xls,append
 
 xi:reg  nervous  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking  i.provcd i.wave i.cmonth if respiratory_disease==1, cluster(provcd)
 outreg2 using subgroup_disease.xls,append
 
 xi:reg  restless  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking  i.provcd i.wave  i.cmonth if respiratory_disease==1, cluster(provcd)
 outreg2 using subgroup_disease.xls,append
 
 xi:reg  hopeless  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking  i.provcd i.wave i.cmonth if respiratory_disease==1, cluster(provcd)
 outreg2 using subgroup_disease.xls,append

 xi:reg  difficult  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking  i.provcd i.wave  i.cmonth if respiratory_disease==1, cluster(provcd)
 outreg2 using subgroup_disease.xls,append
 
 xi:reg  meaningless  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking  i.provcd i.wave i.cmonth if respiratory_disease==1, cluster(provcd)
 outreg2 using subgroup_disease.xls,append
 
  xi:reg  CES_D  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking  i.provcd i.wave  i.cmonth if respiratory_disease==1, cluster(provcd)
 outreg2 using subgroup_disease.xls,append 
 

 xi:reg  depressed  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking  i.provcd i.wave i.cmonth if respiratory_disease==0, cluster(provcd)
 outreg2 using subgroup_disease.xls,append
 
 xi:reg  nervous  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking  i.provcd i.wave i.cmonth if respiratory_disease==0, cluster(provcd)
 outreg2 using subgroup_disease.xls,append
 
 xi:reg  restless  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking  i.provcd i.wave  i.cmonth if respiratory_disease==0, cluster(provcd)
 outreg2 using subgroup_disease.xls,append
 
 xi:reg  hopeless  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking  i.provcd i.wave i.cmonth if respiratory_disease==0, cluster(provcd)
 outreg2 using subgroup_disease.xls,append

 xi:reg  difficult  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking  i.provcd i.wave  i.cmonth if respiratory_disease==0, cluster(provcd)
 outreg2 using subgroup_disease.xls,append
 
 xi:reg  meaningless  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking  i.provcd i.wave i.cmonth if respiratory_disease==0, cluster(provcd)
 outreg2 using subgroup_disease.xls,append
 
 /// heterogenous Effect: Age group  
 ***** Age <18
  xi:reg  CES_D  monthlyAQI  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth if age<18, cluster(provcd)
 outreg2 using Age.xls,replace 
 
 xi:reg  depressed  monthlyAQI    gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth if age<18, cluster(provcd)
 outreg2 using Age.xls,append
 
 xi:reg  nervous  monthlyAQI    gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth if age<18, cluster(provcd)
 outreg2 using Age.xls,append
 
 xi:reg  restless  monthlyAQI    gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth if age<18, cluster(provcd)
 outreg2 using Age.xls,append
 
 xi:reg  hopeless  monthlyAQI    gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth if age<18, cluster(provcd)
 outreg2 using Age.xls,append

 xi:reg  difficult  monthlyAQI    gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth if age<18, cluster(provcd)
 outreg2 using Age.xls,append
 
 xi:reg  meaningless  monthlyAQI    gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth if age<18, cluster(provcd)
 outreg2 using Age.xls,append
 
 
 //// Age:18-65
  xi:reg  CES_D  monthlyAQI  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth if (age>=18)& (age<65), cluster(provcd)
 outreg2 using Age.xls,append 
 

 xi:reg  depressed  monthlyAQI    gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth if (age>=18)& (age<65), cluster(provcd)
 outreg2 using Age.xls,append
 
 xi:reg  nervous  monthlyAQI    gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth if (age>=18)& (age<65), cluster(provcd)
 outreg2 using Age.xls,append
 
 xi:reg  restless  monthlyAQI    gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth if (age>=18)& (age<65), cluster(provcd)
 outreg2 using Age.xls,append
 
 xi:reg  hopeless  monthlyAQI    gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth if (age>=18)& (age<65), cluster(provcd)
 outreg2 using Age.xls,append

 xi:reg  difficult  monthlyAQI    gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth if (age>=18)& (age<65), cluster(provcd)
 outreg2 using Age.xls,append
 
 xi:reg  meaningless  monthlyAQI    gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth if (age>=18)& (age<65), cluster(provcd)
 outreg2 using Age.xls,append
 
 /// Age >65
  xi:reg  CES_D  monthlyAQI  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth if age>=65, cluster(provcd)
 outreg2 using Age.xls,append 
 

 xi:reg  depressed  monthlyAQI    gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth if age>=65, cluster(provcd)
 outreg2 using Age.xls,append
 
 xi:reg  nervous  monthlyAQI    gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth if age>=65, cluster(provcd)
 outreg2 using Age.xls,append
 
 xi:reg  restless  monthlyAQI    gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth if age>=65, cluster(provcd)
 outreg2 using Age.xls,append
 
 xi:reg  hopeless  monthlyAQI    gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth if age>=65, cluster(provcd)
 outreg2 using Age.xls,append

 xi:reg  difficult  monthlyAQI    gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth if age>=65, cluster(provcd)
 outreg2 using Age.xls,append
 
 xi:reg  meaningless  monthlyAQI    gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave i.cmonth if age>=65, cluster(provcd)
 outreg2 using Age.xls,append
 
 
 
clear
use "/Users/csy/Desktop/finaldata4.21.dta"
// Factor Analysis 
factor depressed nervous restless hopeless difficult meaningless
rotate
predict factor1 factor2 // New varialbes factor1, factor2 are generated

xi:reg  factor1  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth, cluster(provcd)
outreg2 using factor.xls,replace 

xi:reg  factor2  monthlyAQI  age  gender  hukou marriage  schooling_years lnindinc lnfpcinc employment health_status smoking disease i.provcd i.wave  i.cmonth, cluster(provcd)
outreg2 using factor.xls, append 
