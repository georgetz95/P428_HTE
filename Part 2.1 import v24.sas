/*
Copywrite Joseph C Vanghelof
last updated Apr 24, 2024
email: joseph_c_vanghelof@rush.edu
*/

libname j 'A:\Data\library';


/*
SectionA1_GenDemo_XT02_v1_SafeHavenID.csv
SectionA2_AlcSmHis_XT02_v1_SafeHavenID.csv
SectionB1_MedicalHistory_XT02_v1_SafeHavenID.csv
SectionB2_PhysicalExam_XT02_v1_SafeHavenID.csv
SectionB3_CancerScreening_XT02_v1_SafehavenID.csv
SectionB4_Pathology_XT02_v1_SafeHavenID.csv
SectionB5_ConMeds_XT02_v1_SafeHavenID.csv
SectionB6_FamilyHistory_XT02_v1_SafeHavenID.csv
SectionB7_MilestoneNonPrescript_XT02_v1_SafeHavenID.csv
SectionC1_3MS_XT02_v1_SafeHavenID.csv
SectionC2_OtherCogs_XT02_v1_SafeHavenID.csv
SectionD1_PhysFunction_XT02_v2_SafeHavenID.csv
SectionE1_LIFE_XT02_v1_SafeHavenID.csv
SectionE2_CESD_XT02_v1_SafeHavenID.csv
SectionE3_SF12_XT02_v1_SafeHavenID.csv
SectionF1_DerivedEndpoints_nejm2019_v1_SafeHavenID.csv
SectionF2_All_Endpoints_XT02_v2_SafeHavenID.csv
SectionF3_SecondaryEndpoints_XT02_v2_SafeHavenID.csv
SectionF4_HospitalisationOtherReason_v3_SafeHavenID.csv
SectionF5_DerivedEndpoints_XT02_v1_SafeHavenID.csv
SectionG1_StudyMed_v3_SafeHavenID.csv
SectionG2_MilestoneQusMeds_XT02_v1_SafeHavenID.csv
SectionG3_LongitudinalAspirinUse(XT)_XT02_v1_SafeHavenID.csv
SectionH1_Visits_XT02_v1_SafeHavenID.csv
SectionI1_DerivedVariables_v3_SafeHavenID.csv
*/



proc import out= j.A1
            DATAFILE= "A:\shared\Resource-XT\CSV Version\SectionA1_GenDemo_XT02_v1_SafeHavenID.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
     GUESSINGROWS=64; 
RUN;

proc import out= j.A2
            DATAFILE= "A:\shared\Resource-XT\CSV Version\SectionA2_AlcSmHis_XT02_v1_SafeHavenID.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
     GUESSINGROWS=64; 
RUN;

proc import out= j.B1
            DATAFILE= "A:\shared\Resource-XT\CSV Version\SectionB1_MedicalHistory_XT02_v1_SafeHavenID.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
     GUESSINGROWS=64; 
RUN;

proc import out= j.B2
            DATAFILE= "A:\shared\Resource-XT\CSV Version\SectionB2_PhysicalExam_XT02_v1_SafeHavenID.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
     GUESSINGROWS=64; 
RUN;

proc import out= j.B4
            DATAFILE= "A:\shared\Resource-XT\CSV Version\SectionB4_Pathology_XT02_v2_SafeHavenID.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
     GUESSINGROWS=19000; 
RUN;

proc import out= j.B5
            DATAFILE= "A:\shared\Resource-XT\CSV Version\SectionB5_ConMeds_XT02_v1_SafeHavenID.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
     GUESSINGROWS=64; 
RUN;

proc import out= j.B6
            DATAFILE= "A:\shared\Resource-XT\CSV Version\SectionB6_FamilyHistory_XT02_v1_SafeHavenID.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
     GUESSINGROWS=64; 
RUN;

proc import out= j.C1
            DATAFILE= "A:\shared\Resource-XT\CSV Version\SectionC1_3MS_XT02_v1_SafeHavenID.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
     GUESSINGROWS=64; 
RUN;

proc import out= j.C2
            DATAFILE= "A:\shared\Resource-XT\CSV Version\SectionC2_OtherCogs_XT02_v1_SafeHavenID.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
     GUESSINGROWS=10000; 
RUN;

proc import out= j.D1
            DATAFILE= "A:\shared\Resource-XT\CSV Version\SectionD1_PhysFunction_XT02_v2_SafeHavenID.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
     GUESSINGROWS=10000; 
RUN;

proc import out= j.E1
            DATAFILE= "A:\shared\Resource-XT\CSV Version\SectionE1_LIFE_XT02_v1_SafeHavenID.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
     GUESSINGROWS=64; 
RUN;

proc import out= j.E2
            DATAFILE= "A:\shared\Resource-XT\CSV Version\SectionE2_CESD_XT02_v1_SafeHavenID.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
     GUESSINGROWS=64; 
RUN;

proc import out= j.E3
            DATAFILE= "A:\shared\Resource-XT\CSV Version\SectionE3_SF12_XT02_v1_SafeHavenID.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
     GUESSINGROWS=64; 
RUN;


proc import out= j.F1
            DATAFILE= "A:\shared\Resource-XT\CSV Version\SectionF1_DerivedEndpoints_nejm2019_v1_SafeHavenID.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
     GUESSINGROWS=64; 
RUN;

proc import out= j.G1
            DATAFILE= "A:\shared\Resource-XT\CSV Version\SectionG1_StudyMed_v3_SafeHavenID.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
     GUESSINGROWS=64; 
RUN;

proc import out= j.I1
            DATAFILE= "A:\shared\Resource-XT\CSV Version\SectionI1_DerivedVariables_v3_SafeHavenID.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
     GUESSINGROWS=64; 
RUN;





/* Decision Tree Groups*/
proc import out= j.DTGroups
            DATAFILE= "A:\Data\DTGroups.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
     GUESSINGROWS=64; 
RUN;
proc freq data=j.DTGroups; table endpoint * subgroups / nopercent norow nocol; run;


/* Random Forest: unweighed */
proc import out= j.RF_Unweighted_Probs_07152023
            DATAFILE= "A:\Data\RF_Unweighted_Probs_07152023.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
     GUESSINGROWS=400; 
RUN;
proc sgplot data= j.RF_Unweighted_Probs_07152023; histogram probability; run;



/* Random Forest: weighed */
proc import out= j.RF_Weighted_Probs_07152023
            DATAFILE= "A:\Data\RF_Weighted_Probs_07152023.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
     GUESSINGROWS=400; 
RUN;



