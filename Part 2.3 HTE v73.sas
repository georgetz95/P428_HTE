/*
Copywrite Joseph C Vanghelof
last updated Apr 24, 2024
email: joseph_c_vanghelof@rush.edu
*/


libname j 'A:\Data\library';



*############################################ Set outcome of interest    ###########################################;
*primary composite endpoint;
%LET my_time_to_event = compPrimEnd_YSR;
%LET my_censor_event  = CompPrimEnd;



*###########################################			Set predictor for porportional hazard models		###########################################;

***** Decision tree;
%LET my_raw_value = DTSubgroups_ordered;					*define the predictor;
%LET my_number_of_percentiles = 6;							*split the predictor into this many percentiles;
%LET risk_grp = DTSubgroups_ordered; 						*define groups for models and table 1: 1) same as raw value 2) risk_grp_auto (uses groups from percentile function) 3) risk_grp_custom (custom ranges set elsewhere);
%LET risk_grp_ref = '0';									*define the referance group;
%LET pretty_title = 'Decision Tree Group';					*pretty name for charts;
proc freq data=j.DTGroups; table subgroups; run;			*1150 subjects, this is the expected amount;

***** Random Forest;
%LET my_raw_value = RF_Weighted_0715_p_raw;					*define the predictor;
%LET my_number_of_percentiles = 5;							*split the predictor into this many percentiles;
%LET risk_grp = risk_grp_auto;								*define groups for models and table 1: 1) raw value 2) risk_grp_auto (uses groups from percentile function) 3) risk_grp_custom (custom ranges set elsewhere);
%LET risk_grp_ref = '0';									*define the referance group (zero is the lowest value for proc rank);
%LET pretty_title = 'Random Forest Quintile';				*pretty name for charts;
proc freq data=j.Rf_weighted_probs_07152023; table RiskQuartile; run;	*1150 subjects, this is the expected amount;

****** Neumann Model;
%LET my_raw_value = neumann_5yr_risk;						*define the predictor;
%LET my_number_of_percentiles = 5;							*split the predictor into this many percentiles, set to 10 groups to copy neumann et al plots;
%LET risk_grp = risk_grp_auto; 								*define groups for models and table 1: 1) raw value 2) risk_grp_auto (uses groups from percentile function) 3) risk_grp_custom (custom ranges set elsewhere);
%LET risk_grp_ref = '0';									*define the referance group;
%LET pretty_title = 'Proportional Hazard Quintile';			*pretty name for charts;












*########################################################################################################################################################################;
*#######################################################			Set population and create number of group		#####################################################;
*########################################################################################################################################################################;


*Restrict on my_raw_value must not be null ;
%LET  restrict_by_null_raw = 1=1;							
%LET  restrict_by_null_raw = &my_raw_value is not null ;


*Restrict on Country;
*set to 1,2 for US AND AUS, set to 2 for US only;
%LET restrict_by_country = and country in (1,2);
%LET restrict_by_country = and country in (2);
%put &restrict_by_country;					*print to log the set value for &my_country;

*restrict by inclusion in Ian / Edwards test set;
%LET restrict_by_test_set = and 1 = 1;
%LET restrict_by_test_set = and test_set_1 = 1;





*Create Restriced dataset: derive_final_v1;
proc sql;
	create table derive_final_v1 as
	select fr.*
	from  j.derive_final_v1 as fr
	where &restrict_by_null_raw
		&restrict_by_country
		&restrict_by_test_set
; quit;

* Create group using the percentiles  "creating quantile groups by jerry leonard 2015 blogs.sas.com" ;
proc rank  data=derive_final_v1 out=HTE_internal_risk_data_rank groups=&my_number_of_percentiles; var &my_raw_value; ranks risk_grp_auto; run;
proc freq  data=HTE_internal_risk_data_rank; table risk_grp_auto / missing norow nocol nopercent ; run;
proc means data=HTE_internal_risk_data_rank n nmiss; var &risk_grp; run;		*n=number of subjects with a non-null value in var   and   nmiss= number of subjects with null value n var;



*create custom groups, log measures, and optionally delete if null ;
proc sql; create table HTE_internal_risk_data as 
	select *,   log(neumann_5yr_risk) as neumann_5yr_risk_log 
		, case  when &my_raw_value < 0.1 					     	then 0
				when &my_raw_value < 0.2 and &my_raw_value 	>=0.1 	then 1
				when &my_raw_value < 0.4 and &my_raw_value 	>=0.2 	then 2
				when &my_raw_value 							>=0.4 	then 3

				else 99 end as risk_grp_custom
		, floor(10*&my_raw_value)/10.0 as risk_rounddown 
	from HTE_internal_risk_data_rank
	order by   sex  ,  risk_grp_auto
;quit; 



*######################################################################################################################################################################;
*############################################################			AUC for raw risk @ 6.5 yr		###############################################################;
*######################################################################################################################################################################;
ods graphics on / width = 5in   height = 5in;
ods text = "***** Note: For figure below: No HTE testing, Cox Proportional Hazard Regression with adjustment for Risk Group ****";
proc phreg data=HTE_internal_risk_data  plots=(roc) rocoptions(at=5 auc method=nne) ;
	model &my_time_to_event * &my_censor_event(0) = &my_raw_value / rl ;
run;
ods graphics on / width = 5in   height = 5in;




*######################################################################################################################################################################;
*#######################################################################			HTE:TTE		#######################################################################;
*######################################################################################################################################################################;

*###########################################		HTE: PH: group + treatment + group * treatment		########################################;
ods text = "***** Note: For table / figure below: HTE testing on the relative scale, Cox Proportional Hazard Regression with adjustment for treatment, risk group, and interaction) ****";
ods output HazardRatios=HR_out_with_interaction;
proc phreg   data=HTE_internal_risk_data;
	class treatment_char(ref='Placebo') &risk_grp (ref = &risk_grp_ref) / param=ref; 	*default is ref, optionally param can set to glm, this changes the presentation style but no the actual estimates when i tried it;
	model &my_time_to_event * &my_censor_event(0) =  treatment_char  |  &risk_grp / rl;		*includes interaction;
	hazardratio treatment_char / at (&risk_grp = ALL) cl=wald;							*cl=both asks for 95% CI to be calcualted 2 ways: wald and profile-liklihood, wald is default, im not sure which is better;
run;
ods output close;



data HR_out_with_interaction_format; set HR_out_with_interaction; 
	index_equal = find(description, "=", 1);

	Q_test  =  compress(		substr(description, index_equal + 1	, length(description) - index_equal 	)		);
	Q_numb  = input(Q_test,2.);

	desc = cats(' ',"Q",Q_test);
run;


ods html dpi = 200;
ods graphics on / width = 5in   height = 5in;
ods text = "***** Note:  Figure 1: HTE on the relative scale (hazard ratio)  ****";
ods text = "***** Note: For figure below: HTE testing on the relative scale, Cox Proportional Hazard Regression with adjustment for treatment, risk group, and interaction) ****";
ods text = "***** Note:  Y-axis label hidden for poster: Hazard Ratio (95% CI) ****";
proc sgplot data=HR_out_with_interaction_format; 
	scatter x=Q_numb    y= hazardratio / yerrorlower=WaldLower yerrorupper=WaldUpper markerattrs=(size=10 symbol=circlefilled) errorbarattrs=(thickness=2);
	xaxis label = &pretty_title           labelattrs=(size=20) valueattrs=(size=15); 
	yaxis display=(nolabel)               labelattrs=(size=20) valueattrs=(size=15) type=log  values = (0.03  0.06  0.12   0.25  0.5   1   2  4  8  16  32)  ;
	refline 1 / axis=y lineattrs=(color=black) ;
	where hazardratio > 0.001;
run;







	















*##################################################################################################################################################################################;
*############################################################			RR and ARD General info needed		#######################################################################;
*##################################################################################################################################################################################;

*calcualte n per group;
ods text = "***** Note: For figure below: calcualte n per group) ****";
proc freq data=HTE_internal_risk_data; table &risk_grp*treatment_char /nopercent norow nocol out=ARD_freq; run;




*##################################################################################################################################################################################;
*#####################################################################			RR and ARD KM 5		###############################################################################;
*##################################################################################################################################################################################;

%LET my_method = KM;
%LET my_km_time = 5;

proc lifetest data=HTE_internal_risk_data outsurv= ARD_KM_5_raw  method=&my_method  reduceout  timelist=&my_km_time   notable  plots=none noprint; * 'reduceout' limits output table to times in timelist ;
	*plots=none and noprint supresses results from table  whereas reduce out and timelist limit outtable results;
	time &my_time_to_event * &my_censor_event(0);
	strata treatment_char    &risk_grp ;
run;

proc sql; 
	create table ARD_KM_5_raw_plus_freq as 
	select fr.*, joi.count as n_strata label = " " 
	from ARD_KM_5_raw fr
	left join (select * from ARD_freq) joi
		on ( fr.treatment_char = joi.treatment_char )  and ( fr.&risk_grp = joi.&risk_grp )
; quit;

*calcualte n per group using the conventional 2x2 a b c d table labeling ;
proc sql; 
	create table ARD_KM_5_match as 
	select asp.&risk_grp , asp.TIMELIST, asp.&my_time_to_event label = " "
		, asp.n_strata   as n_aspirin
		, pla.n_strata  as n_placebo
		, asp.n_strata + pla.n_strata as n_group

		, asp.survival  as survival_asp 
		, pla.survival as survival_pla 

		, (1-asp.survival)*asp.n_strata as a_asa_event
		,    asp.survival *asp.n_strata as b_asa_no_event
		, (1-pla.survival)*pla.n_strata as c_pla_event
		,    pla.survival* pla.n_strata as d_pla_no_event
	from      (select &risk_grp, TIMELIST, &my_time_to_event, survival label = " " , n_strata from ARD_KM_5_raw_plus_freq where treatment_char='Aspirin' and survival is not null) asp 
	left join (select &risk_grp, TIMELIST, &my_time_to_event, survival label = " " , n_strata from ARD_KM_5_raw_plus_freq where treatment_char='Placebo' and survival is not null) pla
		on (  asp.&risk_grp = pla.&risk_grp )  and   (  asp.TIMELIST=pla.TIMELIST  )
	order by asp.&risk_grp , asp.&my_time_to_event
; quit;







*calcualte RR / ARR+CI;
proc sql; create table ARD_KM_5_calc as select *
			,    (EER / CER) as RR  label = 'RR relative riski' format = percentn8.2
			,    (CER - EER) as ARR label = 'ARR absolute risk reduction' format = percentn8.2

			, (CER - EER)-1.965*((   ((EER*(1-EER))/n_aspirin)+((CER*(1-CER))/n_placebo)   ))**0.5 as ARR_lowerCI label = 'ARR 95% CI lower' format = percentn8.2
			, (CER - EER)+1.965*((   ((EER*(1-EER))/n_aspirin)+((CER*(1-CER))/n_placebo)   ))**0.5 as ARR_upperCI label = 'ARR 95% CI upper' format = percentn8.2
			, ((   ((EER*(1-EER))/n_aspirin)+((CER*(1-CER))/n_placebo)   ))**0.5 as ARR_SE label = 'ARR Standard Error' format = percentn8.2

			,    survival_asp - survival_pla as ARR_alternate_equation format = PERCENTn5. label "ARR = surv asp - surv pla"
			, 1/(survival_asp - survival_pla) as NNT_alternate_equation
		from (select * 
				, a_asa_event / n_aspirin as EER label='EER experimental event rate aka ART (absolute risk in treated)' format = 8.2 format = percentn8.2
				, c_pla_event / n_placebo as CER label='CER control event rate aka ARC (absolute risk in control)' format = 8.2 format = percentn8.2
			from ARD_KM_5_match) s1
; quit;

*calcualte NNT+CI;
proc sql; create table ARD_KM_5_calc2 as select *
	, 1/ ARR as NNT label = 'NNT number needed to treat' format = 8.1
	, 1/ ARR_lowerCI as NNT_upper label = 'NNT 95% CI upper' format = 8.1
	, 1/ ARR_upperCI as NNT_lower label = 'NNT 95% CI lower' format = 8.1
	from ARD_KM_5_calc
; quit;




* ARR forest plot at time = 5 ;
ods html dpi = 200;
ods graphics on / width = 5in   height = 5in;
ods text = "***** Note:  Figure 2: HTE on the absolute scale (Absolute Risk Reduction at 5 years)  ****";
ods text = "***** Note: For figure below: Informal HTE testing on the absolute scale, Absolute Risk Reduction at &my_km_time Years, Kaplan-Meier method, stratification by treatment and risk group, with 95% CI ****"; 
ods text = "***** Note: Y-axis label hidden for poster: Absolute Risk Reduction at &my_km_time Years (95% CI) ****";
proc sgplot data=ARD_KM_5_calc2; 
	scatter x=&risk_grp    y= ARR / yerrorlower=ARR_lowerCI yerrorupper=ARR_upperCI markerattrs=(size=10 symbol=circlefilled) errorbarattrs=(thickness=2);
	xaxis label = &pretty_title  labelattrs=(size=20) valueattrs=(size=15);
	yaxis display=(nolabel)      labelattrs=(size=20) valueattrs=(size=15)  values =(-0.2 to 0.4 by .1) ;
	refline 0 / axis=y lineattrs=(color=black) ;
	format ARR percentn5.;
run;





ods text = "***** Note: For table below: Informal HTE testing on the absolute scale, Absolute Risk Reduction (and other stats) at &my_km_time Years, Kaplan-Meier method, stratification by treatment and risk group ****"; 
proc print data=ARD_KM_5_calc2; var &risk_grp TIMELIST &my_time_to_event n_aspirin n_placebo n_group survival_asp survival_pla a_asa_event b_asa_no_event c_pla_event d_pla_no_event; run;

ods text = "***** Note: For table below: Continuation of table above, EER = exposed event rate, CER = control event rate, RR=relative risk, ARR = absolute risk reduction, NNT=number needed to treat ****"; 
proc print data=ARD_KM_5_calc2; var &risk_grp TIMELIST &my_time_to_event EER CER RR ARR ARR_lowerCI ARR_upperCI ARR_SE NNT NNT_lower NNT_upper   ARR_alternate_equation NNT_alternate_equation ; run;





*##################################################################################################################################################################################;
*#######################################################################			events at 5 years		#######################################################################;
*##################################################################################################################################################################################;

%deltable(tables=events_at_5_years);
proc sql;
	create table events_at_5_years as
	select * 
		, event_aspirin_5 / n_aspirin as percent_aspirin_5 format = percentn10.1
		, event_placebo_5 / n_placebo as percent_placebo_5 format = percentn10.1

		, event_aspirin_end / n_aspirin as percent_aspirin_end format = percentn10.1
		, event_placebo_end / n_placebo as percent_placebo_end format = percentn10.1

		, ( event_placebo_5   / n_placebo ) - ( event_aspirin_5   / n_aspirin )  as ARR_5 format = percentn10.1
		, ( event_placebo_end / n_placebo ) - ( event_aspirin_end / n_aspirin )  as ARR_end format = percentn10.1
	from (select &risk_grp
			, count(unique safehaven) as n
			, count(*) as n_verify

			, count(unique case when treatment_char='Aspirin' then safehaven else '' end) as n_aspirin
			, count(unique case when treatment_char='Placebo' then safehaven else '' end) as n_placebo

			, count(unique case when treatment_char='Aspirin' and &my_censor_event = 1 and &my_time_to_event <=5 then safehaven else '' end) as event_aspirin_5
			, count(unique case when treatment_char='Placebo' and &my_censor_event = 1 and &my_time_to_event <=5 then safehaven else '' end) as event_placebo_5

			, count(unique case when treatment_char='Aspirin' and &my_censor_event = 1 then safehaven else '' end) as event_aspirin_end
			, count(unique case when treatment_char='Placebo' and &my_censor_event = 1 then safehaven else '' end) as event_placebo_end
			
			, count(unique case when &my_censor_event = 1 then safehaven else '' end) as event_end
		from HTE_internal_risk_data
		group by &risk_grp
	) fr
; quit;

ods text = "***** Note: For table below: Informal HTE testing on the absolute scale, Absolute Risk Reduction at 5 years and at end of study, uses total number of events (ignores loss to followup data / does not use Kaplan-Meier method) ****"; 
proc print data=events_at_5_years; run;





















