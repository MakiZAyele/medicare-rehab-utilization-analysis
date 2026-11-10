-- This query was ran to find out which PT-related service is the most utilized nationwide
SELECT
  HCPCS_Cd,
  HCPCS_Desc,
  service_category,
  SUM(Tot_Srvcs) AS total_services

FROM
  `invertible-fin-504723-d3.Rehab_Util_exp.PT_Rehab_Analysis`

WHERE
  Rndrng_Prvdr_Geo_Lvl = 'National'

GROUP BY
  HCPCS_Cd,
  HCPCS_Desc,
  service_category

ORDER BY
  total_services DESC;

-- to see if the national totals match the sum of state records by percentage
WITH service_totals AS (
  SELECT
    HCPCS_Cd,
    service_category,

    SUM(
      IF(Rndrng_Prvdr_Geo_Lvl = 'National', Tot_Srvcs, 0)
    ) AS national_services,

    SUM(
      IF(Rndrng_Prvdr_Geo_Lvl = 'State', Tot_Srvcs, 0)
    ) AS state_services

  FROM
    `invertible-fin-504723-d3.Rehab_Util_exp.PT_Rehab_Analysis`

  GROUP BY
    HCPCS_Cd,
    service_category
)

SELECT
  HCPCS_Cd,
  service_category,
  ROUND(national_services, 0) AS national_services,
  ROUND(state_services, 0) AS state_services,
  ROUND(national_services - state_services, 0) AS difference,

  ROUND(
    SAFE_DIVIDE(
      national_services - state_services,
      national_services
    ) * 100,
    2
  ) AS difference_percent

FROM service_totals

ORDER BY difference_percent DESC;

-- Begining comparison of state-level records, first this query was used to see which state had the highest  reported volume of Therapeutic Exercise service 
SELECT
  State,
  SUM(Tot_Srvcs) AS total_services

FROM
  `invertible-fin-504723-d3.Rehab_Util_exp.PT_Rehab_Analysis`

WHERE
  Rndrng_Prvdr_Geo_Lvl = 'State'
  AND HCPCS_Cd = '97110'

GROUP BY
  State

ORDER BY
  total_services DESC;

-- This query was used to see the rank of states based on the highest service units per beneficiary
SELECT
  State,
  ROUND(SUM(Tot_Srvcs), 0) AS total_services,
  SUM(Tot_Benes) AS total_beneficiaries,

  ROUND(
    SAFE_DIVIDE(
      SUM(Tot_Srvcs),
      SUM(Tot_Benes)
    ),
    2
  ) AS services_per_beneficiary

FROM
  `invertible-fin-504723-d3.Rehab_Util_exp.PT_Rehab_Analysis`

WHERE
  Rndrng_Prvdr_Geo_Lvl = 'State'
  AND HCPCS_Cd = '97110'

GROUP BY
  State

ORDER BY
  services_per_beneficiary DESC;

-- The query below was used to see which place of service reported the highest number of therapeutic exrcise service units, how many beneficiary each pace of service had and what their service intensity was
SELECT
  Place_Of_Srvc,
  SUM(Tot_Srvcs) AS total_services,
  SUM(Tot_Benes) AS total_beneficiaries,
  ROUND(
    SAFE_DIVIDE(SUM(Tot_Srvcs), SUM(Tot_Benes)),
    2
  ) AS services_per_beneficiary

FROM
  `invertible-fin-504723-d3.Rehab_Util_exp.PT_Rehab_Analysis`

WHERE
  Rndrng_Prvdr_Geo_Lvl = 'National'
  AND HCPCS_Cd = '97110'

GROUP BY
  Place_Of_Srvc

ORDER BY
  total_services DESC;

-- Then this query was to find out if the pattern for therapeutic Exercise service code is the same for the other selected codes
SELECT
  HCPCS_Cd,
  service_category,
  Place_Of_Srvc,
  ROUND(SUM(Tot_Srvcs), 0) AS total_services,

  ROUND(
    100 * SAFE_DIVIDE(
      SUM(Tot_Srvcs),
      SUM(SUM(Tot_Srvcs)) OVER (PARTITION BY HCPCS_Cd)
    ),
    2
  ) AS percentage_of_service

FROM
  `invertible-fin-504723-d3.Rehab_Util_exp.PT_Rehab_Analysis`

WHERE
  Rndrng_Prvdr_Geo_Lvl = 'National'

GROUP BY
  HCPCS_Cd,
  service_category,
  Place_Of_Srvc

ORDER BY
  HCPCS_Cd,
  Place_Of_Srvc; 

-- This query was used to find out which state had the highest average medicare payment for therapeutic Exercise service unit
SELECT
  State,
  HCPCS_Cd,
  ROUND(Tot_Srvcs, 0) AS total_services,
  ROUND(Avg_Mdcr_Pymt_Amt, 2) AS avg_medicare_payment,
  ROUND(Avg_Mdcr_Stdzd_Amt, 2) AS avg_standardized_payment

FROM
  `invertible-fin-504723-d3.Rehab_Util_exp.PT_Rehab_Analysis`

WHERE
  Rndrng_Prvdr_Geo_Lvl = 'State'
  AND HCPCS_Cd = '97110'
  AND Place_Of_Srvc = 'O'
  AND State NOT IN ('Unknown', 'Guam', 'Virgin Islands')

ORDER BY
  avg_medicare_payment DESC;

-- The results of this query would demonstarte if the difference in the average medicare payment across the states is greater than the difference in the apyment after stadardization
SELECT
  ROUND(MIN(Avg_Mdcr_Pymt_Amt), 2) AS min_payment,
  ROUND(MAX(Avg_Mdcr_Pymt_Amt), 2) AS max_payment,

  ROUND(MIN(Avg_Mdcr_Stdzd_Amt), 2) AS min_standardized,
  ROUND(MAX(Avg_Mdcr_Stdzd_Amt), 2) AS max_standardized,

  ROUND(
    MAX(Avg_Mdcr_Pymt_Amt) - MIN(Avg_Mdcr_Pymt_Amt),
    2
  ) AS payment_range,

  ROUND(
    MAX(Avg_Mdcr_Stdzd_Amt) - MIN(Avg_Mdcr_Stdzd_Amt),
    2
  ) AS standardized_range

FROM
  `invertible-fin-504723-d3.Rehab_Util_exp.PT_Rehab_Analysis`

WHERE
  Rndrng_Prvdr_Geo_Lvl = 'State'
  AND HCPCS_Cd = '97110'
  AND Place_Of_Srvc = 'O'
  AND State IN (
    'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California',
    'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia',
    'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa',
    'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland',
    'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi',
    'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire',
    'New Jersey', 'New Mexico', 'New York', 'North Carolina',
    'North Dakota', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania',
    'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee',
    'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington',
    'West Virginia', 'Wisconsin', 'Wyoming'
  );

-- This query was used to see if the range of the standardized payment is less than the range of the average Medicare payment in all the 14 selected codes
SELECT
  HCPCS_Cd,
  service_category,

  ROUND(
    MAX(Avg_Mdcr_Pymt_Amt) - MIN(Avg_Mdcr_Pymt_Amt),
    2
  ) AS payment_range,

  ROUND(
    MAX(Avg_Mdcr_Stdzd_Amt) - MIN(Avg_Mdcr_Stdzd_Amt),
    2
  ) AS standardized_range

FROM
  `invertible-fin-504723-d3.Rehab_Util_exp.PT_Rehab_Analysis`

WHERE
  Rndrng_Prvdr_Geo_Lvl = 'State'
  AND Place_Of_Srvc = 'O'
  AND State IN (
    'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California',
    'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia',
    'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa',
    'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland',
    'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi',
    'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire',
    'New Jersey', 'New Mexico', 'New York', 'North Carolina',
    'North Dakota', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania',
    'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee',
    'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington',
    'West Virginia', 'Wisconsin', 'Wyoming'
  )

GROUP BY
  HCPCS_Cd,
  service_category

ORDER BY
  HCPCS_Cd;

-- this query will show each state's standardized PT re-evaluation payment alongside its service and beneficiary counts.
SELECT
  State,
  HCPCS_Cd,
  ROUND(Tot_Srvcs, 0) AS total_services,
  Tot_Benes AS total_beneficiaries,
  ROUND(Avg_Mdcr_Pymt_Amt, 2) AS avg_medicare_payment,
  ROUND(Avg_Mdcr_Stdzd_Amt, 2) AS avg_standardized_payment

FROM
  `invertible-fin-504723-d3.Rehab_Util_exp.PT_Rehab_Analysis`

WHERE
  Rndrng_Prvdr_Geo_Lvl = 'State'
  AND HCPCS_Cd = '97164'
  AND Place_Of_Srvc = 'O'
  AND State IN (
    'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California',
    'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia',
    'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa',
    'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland',
    'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi',
    'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire',
    'New Jersey', 'New Mexico', 'New York', 'North Carolina',
    'North Dakota', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania',
    'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee',
    'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington',
    'West Virginia', 'Wisconsin', 'Wyoming'
  )

ORDER BY
  avg_standardized_payment DESC;

-- this query is used to show the difference in the standardized payment range with and without the standardized payments of Nevada and Michigan
SELECT
  ROUND(
    MAX(Avg_Mdcr_Stdzd_Amt) -
    MIN(Avg_Mdcr_Stdzd_Amt), 2
  ) AS full_range,

  ROUND(
    MAX(IF(State NOT IN ('Michigan', 'Nevada'),
      Avg_Mdcr_Stdzd_Amt, NULL)) -
    MIN(IF(State NOT IN ('Michigan', 'Nevada'),
      Avg_Mdcr_Stdzd_Amt, NULL)), 2
  ) AS range_without_two_states

FROM
  `invertible-fin-504723-d3.Rehab_Util_exp.PT_Rehab_Analysis`

WHERE
  Rndrng_Prvdr_Geo_Lvl = 'State'
  AND HCPCS_Cd = '97164'
  AND Place_Of_Srvc = 'O'
  AND State NOT IN (
    'District of Columbia', 'Puerto Rico', 'Guam',
    'Virgin Islands', 'American Samoa',
    'Northern Mariana Islands', 'Unknown',
    'Armed Forces'
  );

-- this query was used to return the difference between facility and non facility settings average payments
WITH payment_comparison AS (
  SELECT
    HCPCS_Cd,
    service_category,

    MAX(IF(
      Place_Of_Srvc = 'F',
      Avg_Mdcr_Pymt_Amt,
      NULL
    )) AS facility_payment,

    MAX(IF(
      Place_Of_Srvc = 'O',
      Avg_Mdcr_Pymt_Amt,
      NULL
    )) AS nonfacility_payment,

    MAX(IF(
      Place_Of_Srvc = 'F',
      Tot_Srvcs,
      NULL
    )) AS facility_services

  FROM
    `invertible-fin-504723-d3.Rehab_Util_exp.PT_Rehab_Analysis`

  WHERE
    Rndrng_Prvdr_Geo_Lvl = 'National'

  GROUP BY
    HCPCS_Cd,
    service_category
)

SELECT
  HCPCS_Cd,
  service_category,
  ROUND(facility_payment, 2) AS facility_payment,
  ROUND(nonfacility_payment, 2) AS nonfacility_payment,
  ROUND(
    SAFE_DIVIDE(
      nonfacility_payment - facility_payment,
      facility_payment
    ) * 100,
    2
  ) AS payment_difference_pct,
  facility_services

FROM payment_comparison

WHERE
  facility_payment IS NOT NULL
  AND nonfacility_payment IS NOT NULL

ORDER BY
  payment_difference_pct DESC;