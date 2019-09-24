# Easy_ICD9-to-10_GEMs_mapping

A SAS macro to quickly map diagnosis and procedure codes using 2018 General Equivalence Mappings (GEMs)

GEMS-based macro (%gemsmap) 



Goal: to map ICD-9-CM to ICD-10-CM diagnosis codes and ICD-9-CM to ICD-10-PCS procedure codes 

Author: Alan Kinlaw

Created: 04 Sep 2019

Updated: 24 Sep 2019

Inputs: Ready-to-go 2018 General Equivalance Mappings (GEMs) SAS datasets which the author has adapted from reference mappings provided in the public domain by the Centers for Medicare and Medicaid Services and the National Center for Health Statistics (NCHS/CDC) [details -- https://bit.ly/2lbh4YJ] [zipfile -- https://go.cms.gov/2lcbDZx (raw text files)].

(a) icd9to10dx.sas7bdat

(b) icd10to9dx.sas7bdat

(c) icd9to10pr.sas7bdat

(d) icd10to9pr.sas7bdat



Steps: 

(1) Identify filepath for projlib directory 
     
(2) Store input files in projlib directory

(3) Run macro code 

(4) For either diagnosis (dx) or procedure (pr) codes of interest, follow instructive comments to progress through mapping and outputting ICD-10-CM/PCS codes

(5) !!! Review the output codes to verify proper inclusion for your project !!! 


Outputs: 

(a) SAS output at end will display all forward-backward-mapped ICD-10-CM/PCS codes of interest, for you to review for your project

(b) A SAS dataset (&condition._&codetype._fbm_final, example: rect_dx_fbm_final.sas7bdat) will display all forward-backward-mapped ICD-10-CM/PCS codes of interest, as well as their simple-forward and simple-backward mapping characteristics -- these may be helpful for guiding your review of codes 

The published material is being distributed without warranty of any kind, either expressed or implied. 
The responsibility for the interpretation and use of the material lies with the reader. 
In no event shall the Author be liable for damages arising from its use.
