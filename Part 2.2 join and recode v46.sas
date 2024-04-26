/*
Copywrite Joseph C Vanghelof
last updated Apr 24, 2024
email: joseph_c_vanghelof@rush.edu
*/

libname j 'A:\Data\library';




proc sql; create table j.d1r as select safehaven
			, coalesce(BL_bothHandsGrip_mean , AV2_bothHandsGrip_mean) as bothHandsGrip_mean_best
			, 3.0/coalesce(    BL_Gait_mean  ,  AV2_Gait_mean  ,  AV3_Gait_mean  )   as Gait_best_m_per_s
	from (select *
			, case when coalesce (BL_RightGrip1, BL_RightGrip2, BL_RightGrip3, BL_LeftGrip1,  BL_LeftGrip2,  BL_LeftGrip3) is null then . else mean(BL_RightGrip1, BL_RightGrip2, BL_RightGrip3, BL_LeftGrip1,  BL_LeftGrip2,  BL_LeftGrip3) end as BL_bothHandsGrip_mean
			, case when coalesce (AV2_RightGrip1, AV2_RightGrip2, AV2_RightGrip3, AV2_LeftGrip1,  AV2_LeftGrip2,  AV2_LeftGrip3) is null then . else mean(AV2_RightGrip1, AV2_RightGrip2, AV2_RightGrip3, AV2_LeftGrip1,  AV2_LeftGrip2,  AV2_LeftGrip3) end as AV2_bothHandsGrip_mean


			, case when coalesce( BL_Gait1  , BL_Gait2  ) is null then . else mean( BL_Gait1  ,  BL_Gait2 ) end as   BL_Gait_mean
			, case when coalesce( AV2_Gait1 , AV2_Gait2 ) is null then . else mean( AV2_Gait1 , AV2_Gait2 ) end as  AV2_Gait_mean
			, case when coalesce( AV3_Gait1 , AV3_Gait2 ) is null then . else mean( AV3_Gait1 , AV3_Gait2 ) end as  AV3_Gait_mean
		from j.d1) as s1
;
quit;


/*	join data	*/
proc delete data=j.join; run;
proc sql;
	create table j.join as
	select a1.*
		, a2.BL_SmHis
		, b1.asp
		, b2.BL_BMI
		, b4.BL_eGFR_MDRD
		, c1.BL_3MS_OverallScore
		, d1r.bothHandsGrip_mean_best, Gait_best_m_per_s
		, e2.BL_CesdOverall
		, f1.CompPrimEnd, compPrimEnd_DSR, compPrimEnd_DSR/365.25 as compPrimEnd_YSR
		, g1.treatment
		, i1.diab_deriv, frailty_deriv, MCS_deriv, PCS_deriv
	from j.A1
	left join j.a2  on a1.safehaven =  a2.safehaven
	left join j.b1  on a1.safehaven =  b1.safehaven
	left join j.b2  on a1.safehaven =  b2.safehaven
	left join j.b4  on a1.safehaven =  b4.safehaven
	left join j.c1  on a1.safehaven =  c1.safehaven
	left join j.d1r on a1.safehaven = d1r.safehaven
	left join j.e2  on a1.safehaven =  e2.safehaven
	left join j.f1  on a1.safehaven =  f1.safehaven
	left join j.g1  on a1.safehaven =  g1.safehaven
	left join j.i1  on a1.safehaven =  i1.safehaven
; quit;



proc delete data=j.cat; run;
proc sql;
	create table j.cat as
	select *
		, case when treatment =1 then 'Aspirin'
			   when treatment =2 then 'Placebo'
			   else 'err'
			   end as treatment_char

		, case when AgeAtRand  <74 then '65-73 yr'
			   when AgeAtRand >=74 then '74+   yr'
			   else 'err'
			   end as Age

		, case when gender =1 then 'Male'
			   when gender =2 then 'Female'
			   else 'err'
			   end as sex

		, case  when country = 1 then 'AUS'
				when country = 2 then 'USA'
				else 'err'
			   end as country_char

		, case when BL_SmHis =1 then 'Current'
			   when BL_SmHis =2 then 'Former'
			   when BL_SmHis =3 then 'Never'
			   else 'err'
			   end as Smoke_baseline

		, case when BL_SmHis in (3,2) then 1 else 0 end as BL_SmHis_never_or_former_1

		, case when diab_deriv =0 then 'No Diabetes'
			   when diab_deriv =1 then 'Diabetes'
			   else 'err'
			   end as diabetes


		, case when asp =0 then 'No Previous regular aspirin'
			   when asp =1 then 'Previous regular aspirin'
			   else 'err'
			   end as Previous_regular_aspirin_use

		, case when frailty_deriv = 0 then '0 not frail'
				when frailty_deriv = 1 then '1 pre frail'
				when frailty_deriv = 2 then '2 frail'
				else 'err'
				end as frailty

		
		, case when BL_3MS_OverallScore is null then . else 5*round(BL_3MS_OverallScore / 5) end as BL_3MS_OverallScore_round
		, case when MCS_deriv is null then . else 10*round(MCS_deriv / 10) end as MCS_deriv_round
		, case when PCS_deriv is null then . else 10*round(PCS_deriv / 10) end as PCS_deriv_round

		, 1 as one
		, 0 as zero
	from j.join
; quit;
*  BL_SmHis key: 1=current   2=former   3=never  ;



proc delete data=j.derive_s1; run;
proc sql;
	create table j.derive_s1 as
	select *
		,case when 	ageatrand is not null 
				and BL_3MS_OverallScore is not null
				and Gait_best_m_per_s is not null
				and BL_BMI is not null
				and BL_CesdOverall is not null
				and bothHandsGrip_mean_best is not null
				and Diab_deriv is not null
				
			then 	ageatrand*0.0812863
				+ 	BL_3MS_OverallScore*-0.0785434
				+	Gait_best_m_per_s * -2.1058784
				+		case when Gait_best_m_per_s > 0.8391608 then ((Gait_best_m_per_s-0.8391608)**3) * 13.6499575 else 0 end
				+		case when Gait_best_m_per_s > 0.9852217 then ((Gait_best_m_per_s-0.9852217)**3) *-27.8419999 else 0 end
				+		case when Gait_best_m_per_s > 1.1257036 then ((Gait_best_m_per_s-1.1257036)**3) * 14.1920424 else 0 end
				+	BL_BMI * -0.0824954
				+		case when BL_BMI > 24.48889 then ((BL_BMI-24.48889)**3) * 0.0022333 else 0 end 
				+		case when BL_BMI > 27.46667 then ((BL_BMI-27.46667)**3) *-0.0040281 else 0 end 
				+		case when BL_BMI > 31.17188 then ((BL_BMI-31.17188)**3) * 0.0017948 else 0 end 
				+	case when BL_CesdOverall > 8 then 0.3885922 else 0 end
				+	bothHandsGrip_mean_best * -0.0188137
				+ 	case when Diab_deriv = 1 then 0.2644989 else 0 end
			else 999
			end as neumann_LP_female

		,case when	ageatrand is not null 
				and BL_3MS_OverallScore is not null
				and Gait_best_m_per_s is not null
				and bothHandsGrip_mean_best is not null
				and BL_SmHis_never_or_former_1 is not null
				and BL_BMI is not null
				and BL_eGFR_MDRD is not null
				
			then 	ageatrand * 0.0791378
				+ 	BL_3MS_OverallScore * -0.0614952
				+	Gait_best_m_per_s * -0.9872901
				+	bothHandsGrip_mean_best * -0.0175855
				+	case when BL_SmHis_never_or_former_1 = 1 then -0.6700744 else 0 end
				+	BL_BMI *  -0.0809386
				+		case when BL_BMI > 25.29407 then ((BL_BMI - 25.29407 )**3) *  0.0034296 else 0 end
				+		case when BL_BMI > 27.55675 then ((BL_BMI - 27.55675 )**3) * -0.0064518 else 0 end
				+		case when BL_BMI > 30.12438 then ((BL_BMI - 30.12438 )**3) *  0.0030222 else 0 end
				+	BL_eGFR_MDRD * -0.0157298
				+		case when BL_eGFR_MDRD > 63.96903 then ((BL_eGFR_MDRD - 63.96903)**3) *  0.0000532 else 0 end 
				+		case when BL_eGFR_MDRD > 74.24563 then ((BL_eGFR_MDRD - 74.24563)**3) * -0.0001092 else 0 end 
				+		case when BL_eGFR_MDRD > 84.00224 then ((BL_eGFR_MDRD - 84.00224)**3) *  0.0000560 else 0 end 
		
			else 888
			end as neumann_LP_male
	from j.cat
; quit;


proc delete data=j.derive_s2; run;
proc sql;
	create table j.derive_s2 as
		select *
		, case  when sex = 'Female' then case when neumann_5yr_risk_female = 999 then 999 else neumann_5yr_risk_female end 
				when sex = 'Male'   then case when neumann_5yr_risk_male   = 888 then 888 else neumann_5yr_risk_male   end 
				else 777
				end as neumann_5yr_risk_err_code

		, case  when sex = 'Female' then case when neumann_5yr_risk_female = 999 then . else neumann_5yr_risk_female end 
				when sex = 'Male'   then case when neumann_5yr_risk_male   = 888 then . else neumann_5yr_risk_male   end 
				else .
				end as neumann_5yr_risk
	from (
		select * 
			, case when neumann_LP_female_exp = 999 then 999 else     1-((4.787198 * (10**-8))**neumann_LP_female_exp) end as neumann_5yr_risk_female
			, case when neumann_LP_male_exp   = 888 then 888 else     1-((5.304956 * (10**-8))**neumann_LP_male_exp)   end as neumann_5yr_risk_male

			from ( 
				select * 
					, case when neumann_LP_female = 999 then 999 else exp(neumann_LP_female) end as neumann_LP_female_exp
					, case when neumann_LP_male   = 888 then 888 else exp(neumann_LP_male)   end as neumann_LP_male_exp
				from j.derive_s1
			) s1
	) s2
; quit;




proc delete data=j.derive_final_v1; run;
proc sql;
	create table j.derive_final_v1 as
	select fr.* 	
		, x1.Subgroups as DTSubgroups_char
			, case  when x1.Subgroups = 'A' then 0
					when x1.Subgroups = 'B' then 1
					when x1.Subgroups = 'C' then 2
					when x1.Subgroups = 'D' then 3
					when x1.Subgroups = 'E' then 4
					when x1.Subgroups = 'F' then 5
					else . end as DTSubgroups
			, case  when x1.Subgroups = 'A' then 0.28
					when x1.Subgroups = 'B' then 0.69
					when x1.Subgroups = 'C' then 0.14
					when x1.Subgroups = 'D' then 0.23
					when x1.Subgroups = 'E' then 0.77
					when x1.Subgroups = 'F' then 0.72
					else . end as DTSubgroups_pct
			, case  when x1.Subgroups = 'A' then 2
					when x1.Subgroups = 'B' then 3
					when x1.Subgroups = 'C' then 0
					when x1.Subgroups = 'D' then 1
					when x1.Subgroups = 'E' then 5
					when x1.Subgroups = 'F' then 4
					else . end as DTSubgroups_ordered   
			, case when x1.Subgroups is null then 0 else 1 end as test_set_1 
		, x2.RiskScore as RF_Weighted_0715_p_raw  

	from j.derive_s2 fr
	left join j.DTGroups      					x1
		on   fr.safehaven =   					x1.ID
	left join j.RF_Weighted_Probs_07152023 		x2
		on fr.safehaven =    	 				x2.ID
; quit; 

















