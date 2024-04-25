# Background

This Github repository contains the code necessary to reproduce the results presented in “Outcome risk model development for heterogeneity of treatment effect analyses: A comparison of non-parametric machine learning methods and semi-parametric statistical methods” by Edward Xu, Joseph C Vanghelof, Yiyang Wang, Anisha Patel, Jacob Furst, Daniela Stan Raicu, Johannes Tobias Neumann, Rory Wolfe, Caroline X. Gao, John J McNeil, Raj C. Shah, and Roselyne Tchoua.

Part 1 of this code creates models using patient data from the [ASPREE trial](https://aspree.org/). 
Part 2 partitions participant into subgroups and measures the ability of the models to 1) predict participant outcomes and 2) demonstrate heterogeneity of treatment effect.
Part 1 and 2 are written in python and SAS respectively. 

This work is done in collaboration between the [Berman Center for Clinical Outcomes and Research](https://www.hhrinstitute.org/our-research/berman-center-for-clinical-outcomes-and-research/), [Rush University Medical Center](https://www.rush.edu/), and [DePaul University](https://www.depaul.edu/Pages/default.aspx). 

# Part 1: Models for generating subgroups and descriptive statistics

## 1.1 Data processing and cleaning
Description TBD

## 1.2 DT Final.Rmd
Description TBD

## 1.3 Random Forest Creation.Rmd
Description TBD

## 1.4 RF_Prob_Analysis.ipynb
Description TBD

## 1.5 Random Forest Weighted Risk.ipynb
Description TBD

## 1.6 Tables and Stats.ipynb
Description TBD


# Part 2: Model Assessment

## 2.1: import v24.sas
This code imports into SAS 1) ASPREE participant data; 2) the decision tree groups; and 3) the random forest predicted risk.

## 2.2: join and recode v46.sas
This code joins together several participant data tables into one consolidated table. First, specific columns from 10 of the ASPREE participant tables are combined, e.g. age at randomization, and randomization to aspirin or placebo. Some measures are recoded, e.g. when gender is equal to 1, it is converted to ‘Male’. Second the code contains an implementation of the predictive model documented in “Prediction of disability-free survival in healthy older people” Neumann JT, Thao LTP, Murray AM, et al. GeroScience. 2022. Third, the decision tree groups and random forest predicted risk are incorporated into the consolidated table. 

## 2.3: HTE v73.sas
This code assess heterogeneity of treatment effect.

First, the outcome of interest is specified by the following macro variables:
-my_time_to_event 
-my_censor_event

Second, the model to be assessed is selected using the following macro variables:
-my_raw_value (the predicted risk or group number assigned to the participant)
-my_number_of_percentiles (the number of groups by which to partition participants)
-risk_grp (if the model assigns predicted risks to participants, then this should be set to risk_grp_auto; however, if the model assigns participants to groups, then set this variable to the same value as my_raw_value)
-risk_grp_ref (specifies the group to be used as the reference group, typically group 0)
-pretty_title (specifies text that can be used in plot titles)

Third, the participants to be used in the HTE analysis are selected into the table derive_final_v1. 

Fourth, proc rank is used to partition participants. Code is also provided if groups based on a priori value ranges are desired rather than groups based on percentiles. 

Fifth, proc phreg is used to compute the area under the receiver operating characteristic curve for use in Table 2 and Appendix 4.

Sixth, proc phreg is used to compute the treatment hazard ratio for each subgroup. These results are presented in Appendix 5. The hazard ratios are output to a table and plotted using proc sgplot. 

Seventh, the absolute risk reduction (ARR) is computed. First, the number of participants in each treatment x risk group is computed. The time at which ARR is computed is set by the macro variable my_km_time. Then proc lifetest is used to compute the survival rate at the time specified by the macro variable, using the method specified by my_method. The equations provided in Appendix 3 are implemented to compute the ARR and confidence interval and the results are presented in Figure 2 and Appendix 5. Last the total number of events are computed in each treatment arm and subgroup, results are presented in Appendix 5.

## 2.4: table 2 v14.sas
Computes the model accuracy, sensitivity, specificity, and positive predictive value for Table 2. These values are computed for the model specified in the macro variable my_pvo_raw_value

# License

License TBD.
