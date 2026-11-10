# Medicare Rehabilitation Utilization & Payment Analysis (2023)

## Overview
An exploratory analysis of selected physical therapy–related services reported in the **2023 Medicare Physician & Other Practitioners by Geography and Service** data. The project examines how reported service volume, service intensity, and average Medicare professional payments vary across states, HCPCS procedures, and facility vs. non-facility settings.

**Tools:** Google BigQuery (SQL), Tableau Public.

**Tableau dashboard:** https://public.tableau.com/app/profile/maraki.alemu/viz/Book1_17942568161220/RehabUtilizationExplorer-UtilizationOverview

## Questions
1. Which selected rehabilitation procedures have the highest reported service volume, and how do states compare in volume versus service intensity?
2. How do average Medicare payments differ across states before versus after standardization?
3. How do reported service volume and average professional payments differ between facility and non-facility settings?

## Data and methodology
- **Source:** [CMS Medicare Physician & Other Practitioners by Geography and Service](https://data.cms.gov/provider-summary-by-type-of-service/medicare-physician-other-practitioners/medicare-physician-other-practitioners-by-geography-and-service), 2023.
- Selected **14 PT-related HCPCS codes** with a BigQuery reference table; the analysis table contains **886 published summary rows** (859 state-level and 27 national-level) spanning **12 service categories**.
- Validated missing/blank values, duplicate keys, numeric ranges, and logical consistency; joined selected codes to the CMS source table.
- Used **national rows** for nationwide procedure and care-setting comparisons and **state rows** for geographic comparisons. Avoided summing state and national totals together.
- Restricted the payment variation comparison for HCPCS **97110** to the **50 states** and **non-facility (`O`)** records.
- Defined reported service intensity as `SUM(Tot_Srvcs) / SUM(Tot_Benes)` for the relevant reporting groups; see limitations on beneficiaries across settings.

## Selected findings
- Therapeutic exercise (**97110**) was the highest-volume procedure among selected codes in national reported service units.
- **New York** had the highest reported therapeutic exercise volume (approximately **6.84 million units**); **New Jersey** had the highest reported therapeutic exercise intensity (approximately **29.98 units per reported beneficiary**).
- For therapeutic exercise in non-facility settings, **Alaska** had the highest state average Medicare payment (**$23.90** per service unit) and a standardized average of **$18.27**.
- Across the 50 states for that procedure and setting, the interstate range of actual state average Medicare payments was about **$7.66**, versus **$1.20** after standardization.
- Non-facility settings represented **over 99%** of national reported units across selected procedures. They had higher average professional Medicare payments for **10 of 13** procedures that had records in both settings.
- Exploratory sensitivity analysis of **97164 (PT re-evaluation)** found that excluding Michigan and Nevada reduced the observed non-facility standardized state payment range from **$12.04** to **$2.99**. The states were excluded only in this diagnostic comparison, not from the principal analysis.

## Repository structure
```text
01_data_cleaning_rehab.sql   # Validation, HCPCS reference table, analysis table
02_EDA_rehab_services.sql    # Utilization, geography, payments, sensitivity analyses
README.md
```

## Limitations
- These are **aggregate Original Medicare Part B professional-claims summaries**, not all outpatient physical therapy services or all patients in the United States. PT-related HCPCS codes are not exclusive to physical therapists.
- The `F` / `O` categories reflect **facility/non-facility professional billing settings**, not the entirety of institutional payments or costs of care.
- State-level geography reflects **rendering-provider location**, not necessarily patient residence.
- `Tot_Srvcs` counts **reported service units**, not visits; summed beneficiary counts across facility and non-facility records may count some people in more than one setting.
- Geographic payment ranges are descriptive and are influenced by the state observations included; standardization does not eliminate all between-state variation.
- Published summary data may omit or suppress some cells. Differences between national totals and sums of published state totals should not automatically be attributed to one specific cause.
- No causal claims or direct assessments of care quality can be made from this data.

## Reproducibility
Run the queries in `01_data_cleaning_rehab.sql` to review validation and build the reference and analysis tables, then explore with `02_EDA_rehab_services.sql`. SQL uses the original BigQuery project and dataset identifiers; **replace those identifiers and load the source CMS data** if running in a different environment. Sections contain independent exploratory queries, not a fully automated deployment pipeline. **The downloadable SQL copies have had the note headings converted to SQL comments and one stray `SELECT` removed; they have not been rerun in BigQuery in this environment.**
