/*
Copywrite Joseph C Vanghelof
last updated Apr 24, 2024
email: joseph_c_vanghelof@rush.edu
*/

*######################################################################################################################################################################;
*####################################################################			select group		###################################################################;
*######################################################################################################################################################################;

****** Random Forest ;
%LET my_pvo_raw_value = RF_Weighted_0715_p_raw;			*raw value for groups;


****** Decision tree ;
%LET my_pvo_raw_value = DTSubgroups_pct;			*raw value for groups;


****** Neumann Model;
%LET my_pvo_raw_value = neumann_5yr_risk;			*raw value for groups;


*######################################################################################################################################################################;
*####################################################################			sens spec ppv		###################################################################;
*######################################################################################################################################################################;

proc sql; 
	create table sens_spec as 
	select safehaven,    &my_censor_event,     &my_pvo_raw_value
		, predicted_1
		, case when predicted_1 = &my_censor_event then 1 else 0 end as acc
	from (select *, case when &my_pvo_raw_value >= 0.5 then 1 when &my_pvo_raw_value < 0.5 then 0 else 2 end as predicted_1 from HTE_internal_risk_data)
	order by  predicted_1 desc, &my_censor_event desc; 
;quit;


*show all counts;
proc freq data=sens_spec;
	table predicted_1 * &my_censor_event / missing nopercent norow nocol; *confirm nobody has predicted_1 = 2;
run;

*compute sens, spec, ppv, npv;
proc freq data=sens_spec order=data;
	table predicted_1 * &my_censor_event / senspec; * per SAS usage note 24170, the prognostic indicator goes first 'test in the example' and the outcome event second 'responce in the example';
	exact binomial;
run;

*compute accuracy;
proc freq; table acc / binomial(level="1"); exact binomial; run;

