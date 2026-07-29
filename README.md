# FinLend Solutions Fraud Analytics

Designed an end-to-end fraud analytics solution that transformed 250,000 payment transactions into executive insights on fraud exposure, operational risk, and control opportunities. The solution combines SQL Server, dimensional modeling, and Power BI to help business leaders understand where fraud occurs, which customer and merchant segments drive losses, and which risk indicators deserve immediate attention.

Rather than building a fraud detection model, the objective was to provide decision-makers with the analytical visibility required to prioritize fraud mitigation efforts using evidence instead of assumptions.

**Author:** Abijah Kabiro | Business Intelligence Analyst | Nairobi, Kenya
**Technology Stack:** SQL Server • SSMS • Power BI • DAX • Power Query
**Dataset:** Synthetic, AI-assisted dataset containing 250,000 payment transactions across eight African markets. The data was intentionally designed to replicate realistic transaction behavior, common data quality issues, and fraud patterns typically encountered within digital payments.
**Project Focus:** Business Intelligence • Fraud Analytics • Data Quality • Operational Risk • Executive Reporting


---

## Business Context

FinLend Solutions is a fictional digital payments company operating across eight African markets: Kenya, Nigeria, Ghana, South Africa, Egypt, Tanzania, Uganda, and Rwanda. The platform supports peer-to-peer transfers, merchant payments, and mobile wallet transactions.

As transaction volumes expanded, fraud-related losses increased by approximately 40% year over year. While leadership could measure the financial impact, they lacked visibility into where fraud was concentrated, which customer and merchant segments generated the greatest exposure, and which operational controls would produce the highest return.

Without this visibility, fraud prevention efforts risked becoming reactive, expensive, and overly restrictive for legitimate customers.

This project was designed to bridge that gap by transforming raw transaction data into actionable business intelligence. Instead of focusing on predictive fraud detection, the solution equips decision-makers with clear analytical insights that support risk prioritization, operational monitoring, and evidence-based fraud mitigation strategies.
---

## About the Dataset

FinLend Solutions is fictional, and the dataset is synthetic.

Access to production fraud data is typically restricted because of privacy, regulatory, and commercial considerations. To simulate a realistic business environment, the dataset was intentionally engineered using AI-assisted generation techniques to mirror common fintech transaction patterns, operational data quality issues, and fraud behaviors.

The data includes intentionally introduced inconsistencies such as missing values, duplicate records, inconsistent country labels, placeholder information, and invalid transactions. These issues were preserved to replicate the challenges Business Intelligence teams encounter before meaningful analysis can begin.
---

## Business Objectives

The analytical solution was designed to answer four strategic business questions that directly support fraud management and operational decision-making.

### 1. Fraud Exposure

Identify where fraud is occurring across the business.

- Which payment methods exhibit the highest fraud rates?
- Which merchant categories generate the greatest fraud exposure?
- Which countries and cross-border payment corridors present elevated risk?
- During which hours of the day does fraud concentrate?

### 2. Customer and Merchant Risk

Understand who contributes most to fraud losses.

- Which merchants account for the highest fraud value?
- Which customers generate disproportionate financial exposure?
- How does customer tenure influence fraud risk?
- Does Know Your Customer (KYC) verification reduce fraud?

### 3. Operational Risk Indicators

Identify behaviors that consistently precede fraudulent transactions.

- Does an IP country mismatch increase fraud risk?
- Are newly registered customers more susceptible to fraud?
- Do transaction velocity spikes indicate coordinated fraud activity?

### 4. Executive Performance Monitoring

Measure the scale and direction of fraud over time.

- What is the organization's overall fraud rate?
- How much revenue is lost to fraudulent transactions?
- Is fraud increasing over time?
- Which business segments contribute the largest share of fraud losses?

---

## Business Value

The completed analytical solution enables business stakeholders to:

- Monitor fraud performance through executive-level KPIs.
- Prioritize fraud investigations using customer and merchant risk profiles.
- Identify high-risk payment corridors requiring additional controls.
- Measure the financial impact of fraud across products and markets.
- Detect operational weaknesses such as IP-country mismatches and high-risk customer onboarding patterns.
- Support evidence-based fraud mitigation strategies without applying blanket restrictions that negatively affect legitimate customers.
---

## Solution Architecture

The solution was developed using a structured Business Intelligence workflow designed to ensure data reliability, analytical consistency, and scalable reporting.

```text
Raw CSV Files
      │
      ▼
SQL Server Staging Layer
      │
      ▼
Data Quality Assessment
      │
      ▼
Data Cleaning & Standardization
      │
      ▼
Dimensional Modeling (Star Schema)
      │
      ▼
Power BI Semantic Model
      │
      ▼
Interactive Executive Dashboard
```

Each stage builds upon the previous one, creating an auditable analytics pipeline that preserves raw source data while producing trusted business insights for decision-makers.

## Phase 1: Data Ingestion and Staging

A SQL Server staging architecture was created to preserve raw source data before transformation.

Four staging tables were developed using NVARCHAR data types to ensure the ingestion process could accommodate inconsistent source values without failing. This approach allowed data quality issues to be identified and measured before applying any transformation logic.

The four source datasets were loaded using BULK INSERT and validated against expected record counts:

| Dataset | Records |
|---|---:|
| Transactions | 250,000 |
| Customers | 15,000 |
| Merchants | 1,500 |
| Geography | 8 |

This staging layer provided an auditable foundation for downstream profiling, cleansing, and analytical modeling.

## Phase 2: Data Quality Assessment

Before transforming the data, a structured data quality assessment was performed to establish a measurable baseline.

Six validation checks were developed to identify completeness, consistency, accuracy, and integrity issues.

| Quality Check | Finding |
|---|---|
| Missing values | 10,005 missing device IDs, 7,507 missing IP addresses, 2,505 missing currency values |
| Country standardization | Multiple variations caused by inconsistent casing, abbreviations, and whitespace |
| Invalid amounts | 405 transactions contained zero or negative values |
| Future timestamps | 60 records contained identical future timestamps indicating a potential system issue |
| Duplicate transactions | 5,000 duplicate records across 2,500 duplicate groups |
| Placeholder emails | 90 records contained invalid placeholder email values |

Profiling before cleansing ensured every transformation decision was evidence-based and traceable. Data quality improvements were measured rather than assumed.
## Phase 3: Data Transformation and Validation

The transformation process converted raw staging data into clean analytical tables suitable for reporting and analysis.

Dimensions were standardized first to establish trusted reference data before processing the transaction fact table. The final fact table transformation resolved all identified quality issues through a controlled SQL workflow using:

- TRY_CONVERT() for safe data type conversion
- CASE statements for standardization logic
- NULLIF() for controlled missing value handling
- ROW_NUMBER() for duplicate detection and removal

Post-transformation validation confirmed:

| Validation | Result |
|---|---:|
| Clean transactions | 247,040 |
| Standardized countries | 8 |
| Payment methods | 5 |
| Remaining duplicates | 0 |
| Orphaned foreign keys | 0 |

Invalid customer email values were flagged using an `is_valid_email` indicator rather than removed.

This approach preserved transaction history and maintained referential integrity while allowing reporting users to identify data quality concerns.

## Phase 4: Analytical Development

The cleaned analytical model was used to answer the business questions defined during project planning.

SQL analysis was developed across customer, merchant, geographic, and transactional dimensions to identify fraud concentration, behavioral patterns, and operational risk factors.

Analytical techniques included:

- Multi-table joins
- Common Table Expressions (CTEs)
- Window functions
- Ranking analysis
- Time-series analysis
- Customer tenure segmentation
- Fraud rate calculations
- Merchant risk scoring
- Geographic corridor analysis
- Transaction velocity detection

Each analytical query was designed around a specific business decision, ensuring technical outputs translated into actionable insights.

## Phase 5: Query Performance Optimization

Performance optimization was performed after establishing a baseline execution profile.

The initial analytical query generated:

- Logical reads: 4,368
- CPU time: 172ms
- Elapsed time: 213ms

Optimization activities included:

- Clustered index implementation
- Four nonclustered indexes
- Covering index creation on transaction_timestamp
- Rewriting inefficient correlated subqueries using window functions

After optimization:

| Metric | Before | After | Improvement |
|---|---:|---:|---:|
| Logical reads | 4,368 | 658 | 85% reduction |
| CPU time | 172ms | 94ms | 45% faster |
| Elapsed time | 213ms | 116ms | 46% faster |

The optimization process demonstrated that analytical performance improvements should be measured through before-and-after evidence rather than assumptions.

## Phase 6: Executive Dashboard Development

The final analytical model was translated into a five-page Power BI executive reporting solution.

The dashboard was built on a star schema architecture consisting of:

- One transaction fact table
- Four supporting dimensions
- DAX-based KPI calculations
- Regional Row-Level Security

Each dashboard page was designed around a specific business question:

1. Executive Overview  
2. Fraud Trends  
3. Merchant Risk  
4. Geographic Analysis  
5. Customer Risk Profiles  

The dashboard was designed to move beyond visualization by connecting every analytical finding to a potential business action.
---

# Executive Insights

The analysis identified seven business insights that explain where fraud exposure is concentrated and where mitigation efforts should be prioritised.

## 1. Fraud Exposure Increased by 39%

Fraud rate increased from **2.39% in Q1** to **3.32% in Q4**, representing a **39% increase** across the reporting period. The platform processed **$23.87M** in transactions, of which **$917.58K** was identified as fraudulent.

This established that fraud exposure was increasing over time rather than remaining stable, creating the business case for investigating the drivers behind the trend.

---

## 2. Fraud Was Concentrated Within High-Risk Merchant Categories

Fraud risk was not evenly distributed across merchants.

| Merchant Category | Fraud Rate |
|-------------------|-----------:|
| Crypto Exchange | **10.12%** |
| Gift Cards | **8.46%** |
| Betting | **7.37%** |
| Gaming | **6.90%** |

The platform-wide fraud rate was **2.93%**, while Groceries (**1.44%**) and Utilities (**1.21%**) remained comparatively low.

**Business implication:** Fraud controls should be prioritised according to merchant risk rather than applied uniformly across the platform.

---

## 3. New Accounts Carried the Highest Fraud Exposure

Customer tenure emerged as one of the strongest fraud indicators.

| Account Age | Fraud Rate |
|-------------|-----------:|
| Under 30 Days | **6.23%** |
| 30–90 Days | **3.69%** |
| 90–365 Days | **2.24%** |
| Over 1 Year | **2.41%** |

The most significant reduction occurred after the first month.

**Business implication:** New accounts should receive enhanced identity verification, lower transaction limits, and additional behavioural monitoring during onboarding.

---

## 4. IP Country Mismatch Was the Strongest Behavioural Indicator

Transactions where the IP country differed from the transaction country recorded a **6.49% fraud rate**, compared with **2.75%** where both locations matched.

Although legitimate travel and VPN usage can produce location mismatches, the strength of the relationship makes IP mismatch a valuable behavioural signal within a broader fraud risk scoring framework.

**Business implication:** Trigger additional verification when high-value transactions occur alongside IP location inconsistencies.

---

## 5. Overnight Transactions Recorded Elevated Fraud Exposure

Transactions processed between **12:00 AM and 5:00 AM** recorded a **5.59% fraud rate**, while daytime fraud rates remained relatively stable between **2.74% and 2.99%**.

**Business implication:** Transaction timing should contribute to real-time fraud scoring rather than being treated as an isolated rule.

---

## 6. Cross-Border Transaction Corridors Revealed More Than Country-Level Reporting

Country-level fraud rates appeared relatively consistent across all eight markets.

However, analysing cross-border payment corridors revealed substantially stronger patterns.

| Transaction Corridor | Fraud Rate |
|----------------------|-----------:|
| Tanzania → Rwanda | **10.29%** |
| Rwanda → Ghana | **10.09%** |
| Egypt → Ghana | **8.65%** |

**Business implication:** Fraud controls should focus on high-risk payment corridors rather than applying the same strategy across entire countries.

---

## 7. Multiple Risk Indicators Identified the Same Customer

Customer **CUST112663** appeared independently across multiple analytical techniques.

- 82 total transactions
- 37 confirmed fraud transactions
- 45.12% individual fraud rate
- Four high-velocity transaction bursts within 24 hours

The account appeared in both the highest fraud value analysis and the transaction velocity analysis.

**Business implication:** Multiple independent risk indicators significantly increase confidence that an account requires investigation and potential intervention.

---

## Dimensional Data Model

The reporting solution was built using a dimensional star schema designed to support scalable analytics, simplified DAX calculations, and interactive reporting.

| Table | Purpose | Records |
|---------|---------|---------:|
| fact_transactions | Stores transaction-level events | 247,040 |
| dim_customers | Customer attributes | 15,000 |
| dim_merchants | Merchant attributes | 1,500 |
| dim_geography | Geographic reference data | 8 |
| dim_date | Calendar dimension | 366 |

The model follows established dimensional modeling principles with one-to-many, single-direction relationships from each dimension into the transaction fact table. This design minimizes ambiguity, improves query performance, and supports consistent filtering throughout the reporting solution.

Transaction amounts are stored as USD equivalents to enable meaningful cross-market comparisons. The original transaction currency is retained separately within the `local_currency` field to preserve business context while maintaining consistent financial reporting across all regions.

---

## Dashboard Preview

### Page 1: Executive Overview

Provides leadership with a high-level view of fraud exposure across the platform.

Key metrics include: overall fraud rate, total transaction value, fraud losses, chargeback exposure and monthly fraud trend.

The page enables executives to quickly understand whether fraud risk is increasing and where additional investigation is required.

![Page 1 — Executive Overview](PowerBI/Executive_Overview.png)

---

### Page 2: Fraud Trends

Analyzes behavioral patterns associated with fraudulent activity.

Key analyses include: fraud rate by payment method, fraud concentration by transaction hour, IP-country mismatch analysis and fraud type distribution.

The objective is to identify recurring signals that can support earlier fraud intervention.

![Page 2 — Fraud Trends](PowerBI/Fraud_Trends.png)

---

### Page 3: Merchant Risk

Evaluates fraud exposure across merchant segments.

Key analyses include: fraud rate by merchant category, merchant-level risk ranking and transaction volume versus fraud exposure analysis.

This view helps risk teams prioritize monitoring efforts toward merchant categories generating disproportionate losses.

![Page 3 — Merchant Risk](PowerBI/Merchant_Risk.png)

---

### Page 4: Geographic Analysis

Analyzes geographic fraud patterns beyond country-level reporting.

Key analyses include: fraud rates by market, cross-border transaction corridors and high-risk transaction routes.

The analysis revealed that transaction corridors provide stronger fraud signals than country-level comparisons.

![Page 4 — Geographic Analysis](PowerBI/Geographic_Analysis.png)

---

### Page 5: Customer Profiles

Identifies customer segments requiring additional monitoring.

Key analyses include: fraud rate by account tenure, KYC risk comparison, customer fraud exposure ranking and transaction velocity detection.

This page supports investigation teams by highlighting customers displaying multiple risk indicators.

![Page 5 — Customer Profiles](PowerBI/Customer_Profiles.png)

---

## Optimization Results

| Metric | Before indexes | After indexes | Change |
|---|---|---|---|
| Logical reads | 4,368 | 658 | 85% reduction |
| CPU time | 172ms | 94ms | 45% faster |
| Elapsed time | 213ms | 116ms | 46% faster |

Additionally demonstrated a correlated subquery rewrite as a window function, replacing 247,040 individual sub-executions with a single pass over the data.

---

## Row-Level Security Implementation

To demonstrate enterprise reporting practices, regional Row-Level Security (RLS) was implemented within the Power BI semantic model.

Four security roles were created:East Africa, West Africa, Southern Africa and North Africa.

Each role filters the geography dimension, with the relationship propagating security rules automatically throughout the transaction fact table.

This approach allows multiple business teams to operate from a single reporting solution while ensuring users only access data relevant to their assigned region.

Example:

When viewing the dashboard as East Africa, transaction exposure changes from $23.87M globally to $9.04M, with reporting restricted to Kenya, Tanzania, Uganda, and Rwanda.
![Row-Level Security](PowerBI/rls_test2.png)

---

# Business Recommendations

The analysis identified five targeted actions that could reduce fraud exposure while minimizing unnecessary friction for legitimate customers.

## 1. Apply Risk-Based Controls to High-Risk Merchant Categories

Crypto Exchange (10.12%), Gift Cards (8.46%), Betting (7.37%), and Gaming (6.90%) significantly exceed the platform average fraud rate of 2.93%.

These categories represent the highest fraud exposure because funds can be converted quickly into difficult-to-recover assets.

**Recommendation:** Implement enhanced monitoring, transaction limits, and additional verification requirements for high-risk merchant categories rather than applying platform-wide restrictions.

## 2. Strengthen New Account Controls During Early Lifecycle Stages

Customers with accounts under 30 days recorded a 6.23% fraud rate, nearly three times higher than mature accounts.

The first month represents the highest-risk period in the customer lifecycle.

**Recommendation:** Introduce stronger onboarding controls, including: mandatory KYC completion, lower initial transaction limits and increased monitoring during the first 30 days.

## 3. Introduce Adaptive Verification for High-Risk Transaction Signals

IP-country mismatch transactions generated a 6.49% fraud rate, while overnight transactions generated 5.59%.

Both indicators identify transactions with elevated risk without affecting most legitimate activity.

**Recommendation:** Implement step-up verification when multiple risk indicators occur, such as: Geographic mismatch, unusual transaction timing, high-value payments and new account activity

## 4. Monitor High-Risk Cross-Border Corridors

Country-level fraud rates were relatively consistent, but specific transaction corridors showed significantly higher risk.

Examples:

- Tanzania → Rwanda: 10.29%
- Rwanda → Ghana: 10.09%
- Egypt → Ghana: 8.65%

**Recommendation:** Develop corridor-level monitoring rules rather than restricting entire countries, allowing FinLend to target risk more precisely.

## 5. Prioritize Customers Showing Multiple Risk Signals

Customer CUST112663 demonstrated several independent indicators: 37 fraudulent transactions, 45.12% personal fraud rate and 4 velocity bursts within 24 hours

**Recommendation:** Create a customer risk scoring framework combining: fraud history, transaction velocity, geographic anomalies, account tenure and KYC status.

This allows investigation teams to focus resources on customers with the highest probability of risk.

---

# Data Quality Management

Data quality assessment was treated as a core component of the analytical solution rather than a preprocessing step.

Six categories of data quality issues were identified, measured, and resolved:

| Issue | Volume | Root Cause | Resolution |
|---|---:|---|---|
| Duplicate transactions | 2,500 pairs | Payment retry duplication | ROW_NUMBER-based deduplication |
| Country inconsistencies | Thousands | Multiple source formats | Standardized using CASE mappings |
| Payment method variations | Thousands | Manual and legacy entry | Text normalization before mapping |
| Invalid transaction values | 405 | System errors | Removed transactions where amount ≤ 0 |
| Future timestamps | 60 | System clock/timezone issue | Removed records outside reporting period |
| Placeholder emails | 90 | Test or incomplete customer records | Flagged using is_valid_email |

Each transformation was validated using before-and-after counts to ensure data quality improvements were measurable and reproducible.

The final analytical dataset contained:

- 247,040 validated transactions
- 8 standardized countries
- 5 payment methods
- Zero duplicates
- Zero orphaned relationships
---

# Skills Demonstrated

## SQL Server

| Capability | Demonstrated Through |
|------------|----------------------|
| **Data ingestion and staging** | Implemented a two-layer staging architecture using `BULK INSERT` to load 250,000 transactions into SQL Server. All source data was initially staged as text, creating a reliable ETL process that handled data quality issues without load failures. |
| **Data quality management** | Applied a six-stage profiling framework covering missing values, consistency, validity, date integrity, duplicate detection, and pattern validation. Every transformation was supported by measured evidence rather than assumptions. |
| **Data transformation** | Performed type conversion, standardized country and payment method values, removed duplicate records, and validated referential integrity through a structured CTE transformation pipeline. |
| **Analytical SQL** | Used Common Table Expressions (CTEs), window functions, ranking functions, time-series analysis, customer tenure segmentation, merchant risk scoring, geographic corridor analysis, and transaction velocity detection to answer business questions. |
| **Dimensional modelling** | Designed a star schema consisting of fact and dimension tables supporting analytical reporting across customers, merchants, geography, and time. |
| **Performance optimization** | Designed clustered, nonclustered, and covering indexes that reduced logical reads by **85%** and query execution time by **46%**. Replaced a correlated subquery with a single-pass window function to improve scalability. |

---

## Power BI

| Capability | Demonstrated Through |
|------------|----------------------|
| **Data modelling** | Built a star schema with one fact table and four dimensions using single-direction relationships to support scalable reporting and accurate filtering. |
| **DAX** | Developed reusable KPI measures, rolling averages, fraud metrics, and time-intelligence calculations using self-contained measures to improve maintainability and avoid aggregation conflicts. |
| **Executive reporting** | Designed a five-page interactive dashboard aligned to key business questions, enabling decision-makers to identify fraud trends, operational risks, and priority intervention areas. |
| **Data visualization** | Selected visualization types based on analytical objectives, including KPI cards, trend lines, scatter plots, ranked bar charts, geographic analysis, and detailed tables for drill-down reporting. |
| **Dashboard design** | Created a consistent branded reporting experience using custom page layouts, conditional formatting, and a colour palette that emphasizes high-risk metrics and improves usability. |
| **Security** | Implemented Row-Level Security (RLS) using four regional roles, ensuring users could only access data relevant to their assigned geographic region across the entire reporting solution. |

---

# Implementation Challenges and Solutions

Building analytical solutions involves resolving technical issues across data ingestion, database connectivity, modeling, and reporting layers.

The following challenges were encountered and resolved during development.

| Challenge | Root Cause | Resolution |
|---|---|---|
| BULK INSERT file not found | CSV files were stored in a different directory from the configured SQL Server path | Updated file locations and aligned BULK INSERT paths with the actual storage location |
| OneDrive access restrictions during data loading | SQL Server service account could not access cloud-only files | Enabled local file availability using "Always keep on this device" |
| Power BI connection failure | Incorrect SQL Server instance name configuration | Updated connection settings to reference the correct SQL Server Express instance |
| Fraud Rate measure calculation errors | SQL Server BIT fields return TRUE/FALSE values rather than integer values in Power BI | Updated DAX filters to use boolean comparisons |
| Incorrect percentage aggregation in Power BI cards | Default Power BI aggregation created percent-of-total calculations | Rebuilt measures using self-contained VAR-based DAX logic |
| Date hierarchy showing blank values | DATETIME2 fields contained time components that prevented proper date matching | Created appropriate date relationships using transaction dates |
| Incorrect month sorting | Text month names sorted alphabetically by default | Applied Sort by Column using Month Number |
| Incorrect calculated field creation | Created a measure instead of a calculated column | Replaced with row-level calculated column logic |

These issues reinforced the importance of understanding how data moves between systems and how design decisions in one layer affect the entire BI solution.

---

# Lessons Learned

## 1. Stage Data Before Applying Business Logic

Raw transactional data should not be loaded directly into typed analytical tables.

Staging data as text provides flexibility when dealing with inconsistent source systems. Validation and transformation can then occur in a controlled environment without risking failed ingestion processes.

## 2. Data Profiling Should Come Before Data Cleaning

Cleaning without measurement creates undocumented assumptions.

By profiling the dataset first, every transformation decision was supported by evidence. This created a transparent data quality process where improvements could be measured before and after cleansing.

## 3. Preserve Data Lineage by Flagging Issues Instead of Deleting Records

Not every data quality issue requires record removal.

For example, customers with placeholder email addresses still had valid transaction histories. Removing these customers would damage relationships between customer and transaction tables.

The preferred approach was preserving the record while adding an indicator such as `is_valid_email` to identify the quality issue.

## 4. Business Risk Is Often Hidden Below the Aggregate Level

Country-level fraud rates appeared almost identical, ranging from 2.83% to 3.09%.

However, cross-border corridor analysis revealed significantly higher-risk transaction routes exceeding 10%.

The lesson: aggregated reporting can hide operational risk. Effective BI analysis requires drilling into the right level of detail.

## 5. Performance Improvements Require Evidence

Optimization should be measured, not assumed.

Capturing baseline execution metrics before adding indexes provided evidence that performance improvements were real.

The final solution achieved an 85% reduction in logical reads, demonstrating the impact of thoughtful SQL design.

## 6. Synthetic Data Can Still Demonstrate Real Analytical Thinking

Production fraud datasets are rarely publicly available due to privacy and regulatory constraints.

A synthetic dataset can still demonstrate BI capability when the analytical process is transparent, including data quality challenges, modeling decisions, performance considerations, and business recommendations.

---

## How to Run the Project

**SQL Server**
1. Create a database called `FinLend` in SSMS
2. Place the four CSV files (dim_customers, dim_geography, dim_merchants, fact_transactions) in a folder SQL Server can access
3. Open SQL/FinLend.sql in SSMS
4. Update the four BULK INSERT file paths to match your CSV location
5. Run the script section by section: staging, profiling, cleaning, analysis, optimization

**Power BI Dashboard**
1. Open PowerBI/FinLend_fraud_analysis.pbix in Power BI Desktop
2. Update the data source connection to your SQL Server instance name and the FinLend database
3. Navigate between pages using the tabs at the bottom
4. Test RLS by going to Modeling > View as > select a region

---

## File Structure

```
finlend/
│
├── README.md
│
├── dim_customers.csv
├── dim_geography.csv
├── dim_merchants.csv
├── fact_transactions.csv
│
├── SQL/
│   ├── FinLend.sql
│   ├── 1_csv_files_in_folder.png
│   ├── 2_staging_tables_created.png
│   ├── 3_row_count_verified.png
│   ├── 4_missing_data_profile.png
│   ├── 5_inconsistent_values.png
│   ├── 6_bad_amounts.png
│   ├── 7_future_dates.png
│   ├── 8_duplicates.png
│   ├── 9_placeholder_emails.png
│   ├── 10a_geography_cleaned.png
│   ├── 10b_customers_cleaned_flag.png
│   ├── 10b_customers_cleaned_count.png
│   ├── 10c_merchants_cleaned.png
│   ├── 10d_fact_transactions_built.png
│   ├── 11_post_clean_validation.png
│   ├── 12_executive_kpis.png
│   ├── 13_monthly_trend.png
│   ├── 14_quarterly_comparison.png
│   ├── 15_fraud_by_method.png
│   ├── 16_hourly_clustering.png
│   ├── 17_ip_mismatch.png
│   ├── 18_fraud_types.png
│   ├── 19_category_risk_ranked.png
│   ├── 20_merchant_risk_scores.png
│   ├── 21_country_fraud_rates.png
│   ├── 22_cross_border_corridors1.png
│   ├── 22_cross_border_corridors2.png
│   ├── 23_tenure_bands.png
│   ├── 24_top_risk_customers1.png
│   ├── 24_top_risk_customers2.png
│   ├── 25_velocity_rings.png
│   ├── 26_baseline_reads.png
│   ├── 27_indexes_created.png
│   ├── 28_after_optimization_reads.png
│   └── 28b_window_function_rewrite.png
│
└── PowerBI/
    ├── FinLend_fraud_analysis.pbix
    ├── Executive_Overview.png
    ├── Fraud_Trends.png
    ├── Merchant_Risk.png
    ├── Geographic_Analysis.png
    ├── Customer_Profiles.png
    ├── model_auto.png
    ├── power_bi_model.png
    ├── PowerBI_connection1.png
    ├── PowerBI_connection2.png
    ├── rls_roles.png
    ├── rls_test1.png
    └── rls_test2.png
```

---

## Further Reading

For the full project story including business context, technical walkthrough, data quality challenges, and lessons learned, read the Medium article:

[FinLend Solutions Fraud Analysis — Full Article](#) *(https://medium.com/@abijahkabiro/fraud-was-increasing-business-intelligence-revealed-where-finlend-was-most-exposed-401373f9a1d1)*

---

# About This Project

Built by Abijah Kabiro, a Business Intelligence Analyst specializing in SQL, Power BI, analytics, and operational decision support.

This project demonstrates the complete BI lifecycle:

- Understanding a business problem
- Preparing unreliable source data
- Designing analytical models
- Developing scalable reporting solutions
- Optimizing query performance
- Translating insights into business recommendations

The objective was not simply to create dashboards, but to demonstrate how Business Intelligence can transform transactional data into decisions that reduce risk and improve business performance.


**Connect:** [LinkedIn](https://linkedin.com/in/abijahkabiro) · [Portfolio](https://abijahkabiro.github.io) · [Medium](https://medium.com/@abijahkabiro) · [GitHub](https://github.com/Abijahkabiro)
