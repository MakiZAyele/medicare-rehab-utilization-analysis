-- This query checks if all the data in the HCPCS_Drug_Ind column imported correctly into BigQuery by counting how many rows have TRUE and FALSE values.  
SELECT
  HCPCS_Drug_Ind,
  COUNT(*) AS row_count
FROM `invertible-fin-504723-d3.Rehab_Util_exp.Geography and Service`
GROUP BY HCPCS_Drug_Ind
ORDER BY row_count DESC;

-- After this I also had to check if the rows that came up matched all the rows that were imported
SELECT
  COUNT(*) AS total_rows
FROM `invertible-fin-504723-d3.Rehab_Util_exp.Geography and Service`;

-- This query was used to check if HCPCS_Drug_Ind had any NULL values
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(HCPCS_Drug_Ind IS NULL) AS missing_drug_indicator,
  COUNTIF(HCPCS_Drug_Ind IS NOT NULL) AS nonmissing_drug_indicator
FROM 
  `invertible-fin-504723-d3.Rehab_Util_exp.Geography and Service`;

-- Next this query was used to see if there are any NULL values in all the other columns
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(Rndrng_Prvdr_Geo_Lvl IS NULL) AS missing_geo_level,
  COUNTIF(Rndrng_Prvdr_Geo_Cd IS NULL) AS missing_geo_code,
  COUNTIF(Rndrng_Prvdr_Geo_Desc IS NULL) AS missing_geo_desc,
  COUNTIF(HCPCS_Cd IS NULL) AS missing_hcpcs_code,
  COUNTIF(HCPCS_Desc IS NULL) AS missing_hcpcs_desc,
  COUNTIF(HCPCS_Drug_Ind IS NULL) AS missing_drug_ind,
  COUNTIF(Place_Of_Srvc IS NULL) AS missing_place_of_service,
  COUNTIF(Tot_Rndrng_Prvdrs IS NULL) AS missing_providers,
  COUNTIF(Tot_Srvcs IS NULL) AS missing_services,
  COUNTIF(Tot_Benes IS NULL) AS missing_beneficiaries,
  COUNTIF(Tot_Bene_Day_Srvcs IS NULL) AS missing_bene_day_services,
  COUNTIF(Avg_Sbmtd_Chrg IS NULL) AS missing_avg_charge,
  COUNTIF(Avg_Mdcr_Alowd_Amt IS NULL) AS missing_avg_allowed,
  COUNTIF(Avg_Mdcr_Pymt_Amt IS NULL) AS missing_avg_payment,
  COUNTIF(Avg_Mdcr_Stdzd_Amt IS NULL) AS missing_avg_standardized
FROM `invertible-fin-504723-d3.Rehab_Util_exp.Geography and Service`;

-- Since blank strings(" ") are not considered as blank in SQL, this query was used to really check if there are any missing values
SELECT
  COUNTIF(TRIM(Rndrng_Prvdr_Geo_Lvl) = '') AS empty_geo_level,
  COUNTIF(TRIM(Rndrng_Prvdr_Geo_Cd) = '') AS empty_geo_code,
  COUNTIF(TRIM(Rndrng_Prvdr_Geo_Desc) = '') AS empty_geo_description,
  COUNTIF(TRIM(HCPCS_Cd) = '') AS empty_hcpcs_code,
  COUNTIF(TRIM(HCPCS_Desc) = '') AS empty_hcpcs_description,
  COUNTIF(TRIM(Place_Of_Srvc) = '') AS empty_place_of_service

FROM
  `invertible-fin-504723-d3.Rehab_Util_exp.Geography and Service`;

-- When the above query was run, there are 5 blank values in the Rndrng_Prvdr_Geo_Desc column. To see where the blank values are this query was used
 SELECT
  Rndrng_Prvdr_Geo_Lvl,
  Rndrng_Prvdr_Geo_Cd,
  Rndrng_Prvdr_Geo_Desc,
  HCPCS_Cd,
  HCPCS_Desc,
  Place_Of_Srvc

FROM
  `invertible-fin-504723-d3.Rehab_Util_exp.Geography and Service`

WHERE
  TRIM(Rndrng_Prvdr_Geo_Desc) = '';

-- From the query that ran to check if there were any blank values not counted as NULL in the data, there were 13,383 blanks in the  Rndrng_Prvdr_Geo_Cd column. To see from those how many were national-level records and how many were state-level records this query was used
SELECT
  Rndrng_Prvdr_Geo_Lvl,
  COUNT(*) AS empty_code_count

FROM
  `invertible-fin-504723-d3.Rehab_Util_exp.Geography and Service`

WHERE
  TRIM(Rndrng_Prvdr_Geo_Cd) = ''

GROUP BY
  Rndrng_Prvdr_Geo_Lvl

ORDER BY
  empty_code_count DESC;

-- In order to check if there were any duplicates, a certain combination of attributes(columns) were used to check
SELECT
  Rndrng_Prvdr_Geo_Lvl,
  Rndrng_Prvdr_Geo_Desc,
  HCPCS_Cd,
  Place_Of_Srvc,
  COUNT(*) AS duplicate_count

FROM
  `invertible-fin-504723-d3.Rehab_Util_exp.Geography and Service`

GROUP BY
  Rndrng_Prvdr_Geo_Lvl,
  Rndrng_Prvdr_Geo_Desc,
  HCPCS_Cd,
  Place_Of_Srvc

HAVING
  COUNT(*) > 1

ORDER BY
  duplicate_count DESC;

-- This query was used to check if there were any leading or trailing whitespace in the String columns
SELECT
  COUNTIF(TRIM(Rndrng_Prvdr_Geo_Lvl) != Rndrng_Prvdr_Geo_Lvl) AS spaces_geo_level,
  COUNTIF(TRIM(Rndrng_Prvdr_Geo_Cd) != Rndrng_Prvdr_Geo_Cd) AS spaces_geo_code,
  COUNTIF(TRIM(Rndrng_Prvdr_Geo_Desc) != Rndrng_Prvdr_Geo_Desc) AS spaces_geo_description,
  COUNTIF(TRIM(HCPCS_Cd) != HCPCS_Cd) AS spaces_hcpcs_code,
  COUNTIF(TRIM(HCPCS_Desc) != HCPCS_Desc) AS spaces_hcpcs_description,
  COUNTIF(TRIM(Place_Of_Srvc) != Place_Of_Srvc) AS spaces_place_of_service

FROM
  `invertible-fin-504723-d3.Rehab_Util_exp.Geography and Service`;

-- Next to understand the data ranges of the important numerical columns before checking for logical extremes I ran
SELECT
  MIN(Tot_Srvcs) AS min_services,
  MAX(Tot_Srvcs) AS services,

  MIN(Tot_Benes) AS min_beneficiaries,
  MAX(Tot_Benes) AS max_beneficiaries,

  MIN(Avg_Mdcr_Pymt_Amt) AS min_payment,
  MAX(Avg_Mdcr_Pymt_Amt) AS max_payment

FROM
  `invertible-fin-504723-d3.Rehab_Util_exp.Geography and Service`;

-- To make sure that there were no negative values in all the numerical columns
SELECT
  COUNTIF(Tot_Rndrng_Prvdrs < 0) AS negative_providers,
  COUNTIF(Tot_Srvcs < 0) AS negative_services,
  COUNTIF(Tot_Benes < 0) AS negative_beneficiaries,
  COUNTIF(Tot_Bene_Day_Srvcs < 0) AS negative_beneficiary_days,
  COUNTIF(Avg_Sbmtd_Chrg < 0) AS negative_submitted_charges,
  COUNTIF(Avg_Mdcr_Alowd_Amt < 0) AS negative_allowed_amounts,
  COUNTIF(Avg_Mdcr_Pymt_Amt < 0) AS negative_medicare_payments,
  COUNTIF(Avg_Mdcr_Stdzd_Amt < 0) AS negative_standardized_payments

FROM
  `invertible-fin-504723-d3.Rehab_Util_exp.Geography and Service`;

-- This query was used to check how many zeros(if any) are in the number columns
SELECT
  COUNTIF(Tot_Rndrng_Prvdrs = 0) AS zero_providers,
  COUNTIF(Tot_Srvcs = 0) AS zero_services,
  COUNTIF(Tot_Benes = 0) AS zero_beneficiaries,
  COUNTIF(Tot_Bene_Day_Srvcs = 0) AS zero_beneficiary_days,
  COUNTIF(Avg_Sbmtd_Chrg = 0) AS zero_submitted_charges,
  COUNTIF(Avg_Mdcr_Alowd_Amt = 0) AS zero_allowed_amounts,
  COUNTIF(Avg_Mdcr_Pymt_Amt = 0) AS zero_medicare_payments,
  COUNTIF(Avg_Mdcr_Stdzd_Amt = 0) AS zero_standardized_payments

FROM
  `invertible-fin-504723-d3.Rehab_Util_exp.Geography and Service`;

-- The above query gave the result of only one zero in all three payment-related columns, so this query is going to show which records are those zeros in
SELECT
  Rndrng_Prvdr_Geo_Lvl,
  Rndrng_Prvdr_Geo_Desc,
  HCPCS_Cd,
  HCPCS_Desc,
  Place_Of_Srvc,
  Tot_Srvcs,
  Tot_Benes,
  Avg_Sbmtd_Chrg,
  Avg_Mdcr_Alowd_Amt,
  Avg_Mdcr_Pymt_Amt,
  Avg_Mdcr_Stdzd_Amt

FROM
  `invertible-fin-504723-d3.Rehab_Util_exp.Geography and Service`

WHERE
  Avg_Mdcr_Alowd_Amt = 0
  OR Avg_Mdcr_Pymt_Amt = 0
  OR Avg_Mdcr_Stdzd_Amt = 0;

-- To further check for logical extremes, this query was used to see if there were any records that had a greater number of beneficiaries than number of max_services
SELECT
  COUNT(*) AS records_to_investigate
FROM
  `invertible-fin-504723-d3.Rehab_Util_exp.Geography and Service`
WHERE
  Tot_Benes > Tot_Srvcs;

-- To check if the services of the 4 records with the number of beneficiaries greater than the number of services
SELECT
  Rndrng_Prvdr_Geo_Desc,
  HCPCS_Cd,
  HCPCS_Desc,
  Place_Of_Srvc,
  Tot_Benes,
  Tot_Srvcs

FROM
  `invertible-fin-504723-d3.Rehab_Util_exp.Geography and Service`

WHERE
  Tot_Benes > Tot_Srvcs;

-- To narrow down the list of services in the dataset to review and select HCPCS codes related to the project. Based on 97000 series 
SELECT DISTINCT
  HCPCS_Cd,
  HCPCS_Desc
FROM
  `invertible-fin-504723-d3.Rehab_Util_exp.Geography and Service`
WHERE
  SAFE_CAST(HCPCS_Cd AS INT64)
    BETWEEN 97000 AND 97799
ORDER BY
  HCPCS_Cd;

-- After deciding on the selected HCPCS codes, this query was ran to create a reference table of the codes 
 CREATE TABLE
  `invertible-fin-504723-d3.Rehab_Util_exp.PT_Code_Reference`
AS

SELECT '97161' AS HCPCS_Cd, 'PT Evaluation' AS service_category
UNION ALL
SELECT '97162', 'PT Evaluation'
UNION ALL
SELECT '97163', 'PT Evaluation'
UNION ALL
SELECT '97164', 'PT Re-evaluation'
UNION ALL
SELECT '97110', 'Therapeutic Exercise'
UNION ALL
SELECT '97112', 'Neuromuscular Reeducation'
UNION ALL
SELECT '97116', 'Gait Training'
UNION ALL
SELECT '97140', 'Manual Therapy'
UNION ALL
SELECT '97530', 'Therapeutic Activities'
UNION ALL
SELECT '97535', 'Self-care Training'
UNION ALL
SELECT '97750', 'Physical Performance Testing'
UNION ALL
SELECT '97760', 'Orthotic Management and Training'
UNION ALL
SELECT '97761', 'Prosthetic Training'
UNION ALL
SELECT '97763', 'Orthotic/Prosthetic Follow-up Training';

-- After creating a reference table, to join geography and service table with the new reference table and save it 
CREATE TABLE
  `invertible-fin-504723-d3.Rehab_Util_exp.PT_Rehab_Analysis`
AS

SELECT
  medicare.Rndrng_Prvdr_Geo_Lvl,
  medicare.Rndrng_Prvdr_Geo_Cd,
  medicare.Rndrng_Prvdr_Geo_Desc AS State,
  medicare.HCPCS_Cd,
  medicare.HCPCS_Desc,
  therapy.service_category,
  medicare.Place_Of_Srvc,
  medicare.Tot_Rndrng_Prvdrs,
  medicare.Tot_Srvcs,
  medicare.Tot_Benes,
  medicare.Avg_Mdcr_Pymt_Amt,
  medicare.Avg_Mdcr_Stdzd_Amt

FROM
  `invertible-fin-504723-d3.Rehab_Util_exp.Geography and Service`
  AS medicare

INNER JOIN
  `invertible-fin-504723-d3.Rehab_Util_exp.PT_Code_Reference`
  AS therapy

ON
  medicare.HCPCS_Cd = therapy.HCPCS_Cd;

-- The queries after this point was used to validate the new table created by joining the main dataset with the reference table 
-- To see how many rows were saved and if the selected HCPCS codes and service categories are in the table 
SELECT
  COUNT(*) AS total_records,
  COUNT(DISTINCT HCPCS_Cd) AS unique_hcpcs_codes,
  COUNT(DISTINCT service_category) AS service_categories

FROM
  `invertible-fin-504723-d3.Rehab_Util_exp.PT_Rehab_Analysis`;


-- To check how many records are state-level and how many are national-level in the new table
SELECT
  Rndrng_Prvdr_Geo_Lvl,
  COUNT(*) AS total_records

FROM
  `invertible-fin-504723-d3.Rehab_Util_exp.PT_Rehab_Analysis`

GROUP BY
  Rndrng_Prvdr_Geo_Lvl

ORDER BY
  total_records DESC;

-- To see if there were any duplicate records
SELECT
  Rndrng_Prvdr_Geo_Lvl,
  State,
  HCPCS_Cd,
  Place_Of_Srvc,
  COUNT(*) AS duplicate_count

FROM
  `invertible-fin-504723-d3.Rehab_Util_exp.PT_Rehab_Analysis`

GROUP BY
  Rndrng_Prvdr_Geo_Lvl,
  State,
  HCPCS_Cd,
  Place_Of_Srvc

HAVING
  COUNT(*) > 1

ORDER BY
  duplicate_count DESC;

-- To check if the 5 state records that have missing geographic codes from earlier are not in this table
 SELECT
  COUNTIF(
    Rndrng_Prvdr_Geo_Lvl = 'State'
    AND (State IS NULL OR TRIM(State) = '')
  ) AS missing_state_names,

  COUNTIF(
    Rndrng_Prvdr_Geo_Lvl = 'State'
    AND (
      Rndrng_Prvdr_Geo_Cd IS NULL
      OR TRIM(Rndrng_Prvdr_Geo_Cd) = ''
    )
  ) AS missing_state_codes

FROM
  `invertible-fin-504723-d3.Rehab_Util_exp.PT_Rehab_Analysis`;

-- to check if there were any logical extremes in the PT-related dataset
SELECT
  COUNTIF(Tot_Srvcs <= 0) AS invalid_services,
  COUNTIF(Tot_Benes <= 0) AS invalid_beneficiaries,
  COUNTIF(Avg_Mdcr_Pymt_Amt < 0) AS negative_payments,
  COUNTIF(
    Tot_Benes > Tot_Srvcs
  ) AS beneficiaries_exceed_services

FROM
  `invertible-fin-504723-d3.Rehab_Util_exp.PT_Rehab_Analysis`;






