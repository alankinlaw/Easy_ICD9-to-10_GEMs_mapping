
***********************************************************************************************************

GEMS-based macro (%gemsmap) 

Goal: to map ICD-9-CM to ICD-10-CM diagnosis codes and ICD-9-CM to ICD-10-PCS procedure codes 

Author: Alan Kinlaw

Created: 04 Sep 2019
Updated: 24 Sep 2019

Inputs: Ready-to-go 2018 General Equivalance Mappings (GEMs) SAS datasets which the author has adapted from
		reference mappings provided in the public domain by the Centers for Medicare and Medicaid Services and 
		the National Center for Health Statistics (NCHS/CDC).
		1. icd9to10dx.sas7bdat
		2. icd10to9dx.sas7bdat
		3. icd9to10pr.sas7bdat
		4. icd10to9pr.sas7bdat
				[details -- https://bit.ly/2lbh4YJ]
				[zipfile -- https://go.cms.gov/2lcbDZx (raw text files)]

Outputs: 1. SAS output at end will display all forward-backward-mapped 
			ICD-10-CM/PCS codes of interest, for you to review for your project
		 2. A dataset (example: rect_dx_fbm_final) will display all forward-backward-mapped
			ICD-10-CM/PCS codes of interest, as well as their simple-forward and simple-backward
			mapping characteristics -- these may be helpful for guiding your review of codes 

Steps: 1. Identify filepath for projlib directory
	   2. Store input files in projlib directory
	   3. Submit macro code 
	   4. For either diagnosis (dx) or procedure (pr) codes of interest, follow
 		  instructive comments to progress through mapping and outputting ICD-10-CM/PCS codes
	   5. !!! Review the output codes to verify proper inclusion/exclusion of candidate codes for your project !!! 



The published material is shared under a GNU General Public License v3.0. 
It is being distributed without warranty of any kind, either expressed or implied. 
The responsibility for the interpretation and use of the material lies with the reader. 
In no event shall the Author be liable for damages arising from its use.

***********************************************************************************************************;




options ps=500 ls=220 nodate nocenter nofmterr pageno=1 fullstimer stimer stimefmt=z compress=yes mprint;proc template;edit Base.Freq.OneWayList;edit Frequency;format=5.0;end;edit Percent;format = 5.1;end;edit CumPercent;format = 5.1;end;end;run;
 
libname projlib 'FILEPATH WHERE YOU STORE THE MAPPING INPUT FILES AND YOUR OUTPUT DATASETS';
 
%macro gemsmap(condition,codetype);
 
     *FORWARD MAPPING;
           proc sql;
                create table &condition._&codetype._2forward as
                select a.source, a.target, a.flags
                from projlib.icd9to10&codetype as a
                inner join icd9_&codetype._codelist as b
                on a.source = b.icd9_&codetype._self
                order by a.target;
 
                create table &condition._&codetype._distincttargets_forward as
                select distinct target as icd10&codetype, 
                      flags,
                      case when icd10&codetype ne '' then 1 else 0 end as forward
                from &condition._&codetype._2forward
                order by target;
                quit;
 
     *BACKWARD MAPPING;
           proc sql;
                create table &condition._&codetype._2backward as
                select a.source, a.target, a.flags
                from projlib.icd10to9&codetype as a
                inner join icd9_&codetype._codelist as b
                on a.target = b.icd9_&codetype._self
                order by a.source;
 
                create table &condition._&codetype._distinctsources_backward as
                select distinct source as icd10&codetype, 
                      flags, 
                      case when icd10&codetype ne '' then 1 else 0 end as backward
                from &condition._&codetype._2backward
                order by source;
                quit;
 
     *COMBINED FORWARD-BACKWARD MAPPING;
           data &condition._&codetype._fbm_1;
                set &condition._&codetype._distincttargets_forward 
                     &condition._&codetype._distinctsources_backward
                      ;
                array nums _numeric_;
                      do over nums;
                      if nums = . then nums = 0;
                      end;
                run;
                proc sort data = &condition._&codetype._fbm_1 out = &condition._&codetype._fbm_2;
                      by icd10&codetype forward backward;
                      run;
                proc sql;
                      create table &condition._&codetype._fbm_3 as 
                      select icd10&codetype, 
                           flags, 
                           max(forward) as forward_map, 
                           max(backward) as backward_map
                      from &condition._&codetype._fbm_2
                      group by icd10&codetype;
                      quit;
                      proc sort data = &condition._&codetype._fbm_3 out = &condition._&codetype._fbm_4 nodup;
                           by icd10&codetype flags forward_map backward_map;
                           run;
                           data projlib.&condition._&codetype._fbm_final;
                                 set &condition._&codetype._fbm_4;
                                 sfm_simple_forward = forward_map;
                                 sbm_simple_backward = backward_map;
                                 fbm_forward_backward = max(forward_map,backward_map);
                                 drop forward_map backward_map;
                                 run;
 
     /*   proc print data = projlib.&condition._&codetype._fbm_final noobs;*/
     /*         var icd10&codetype;*/
     /*         run;*/
 
     proc sql; select distinct icd10&codetype from projlib.&condition._&codetype._fbm_final; quit; run; quit; run;
 
%mend;
 





***********************************************************************************************************
***********************************************************************************************************;
***********************************************************************************************************;




 
* EXAMPLE USING DIAGNOSIS CODES WHEN YOU KNOW THE ICD-9-CM CODES YOU NEED ;
	* insert your ICD-9-CM diagnosis codes in the WHERE statement below ; 
	* for rectal cancer, my example ICD-9-CM codes are 154.1 and 154.8 ;
		data _0; set projlib.icd9to10dx;
			where source in:('1541','1548');
				run; proc sql; select distinct(source) from _0; quit;
	* read off the codes from SAS output and insert them on separate lines below ;
	* n.b.: these may be more numerous than the ones you entered because of descendant codes 
			you should make sure that you aren't accidentally including any improper ones! ;
	     data icd9_dx_codelist; input icd9_dx_self $; cards;
1541
1548
; run;

	* in the macro call below, 
		(1) use a four-letter text-string to name your dx of interest (ex: rect below) 
		(2) choose either "dx" (diagnosis) or "pr" (procedure) for the type of codes you are identifying ;	
		%gemsmap(rect,dx);

	* your output will contain the ICD-10-CM codes that mapped through forward-backward mapping to the ICD-9-CM codes you provided.
	* the dataset at projlib.&condition._&codetype._fbm_final shows detailed data on which codes matched on:
		(a) sfm (simple forward mapping)
		(b) sbm (simple backward mapping)
		(c) fbm (forward backward mapping)
 





***********************************************************************************************************
***********************************************************************************************************;
***********************************************************************************************************;




 
* EXAMPLE USING PROCEDURE CODES WHEN YOU KNOW THE ICD-9-CM PROCEDURE CODES YOU NEED ;
	* insert your ICD-9-CM procedure codes in the WHERE statement below ; 
	* for lung lobectomy, my example ICD-9-PCS codes are all codes that start with 32.4 (aka 32.4x) ;
		data _1; set projlib.icd9to10pr;
			where source in:('324');
				run; proc sql; select distinct(source) from _1; quit;
	* read off the codes from SAS output and insert them on separate lines below ;
	* n.b.: these may be more numerous than the ones you entered because of descendant codes 
			you should make sure that you aren't accidentally including any improper ones! ;
	     data icd9_pr_codelist; input icd9_pr_self $; cards;
3241
3249
; run;

	* in the macro call below, 
		(1) use a four-letter text-string to name your dx of interest (ex: rect below) 
		(2) choose either "dx" (diagnosis) or "pr" (procedure) for the type of codes you are identifying ;	
		%gemsmap(lulo,pr);

	* your output will contain the ICD-10-PCS codes that mapped through forward-backward mapping to the ICD-9-PCS codes you provided.
	* the dataset at projlib.&condition._&codetype._fbm_final shows detailed data on which codes matched on:
		(a) sfm (simple forward mapping)
		(b) sbm (simple backward mapping)
		(c) fbm (forward backward mapping)

