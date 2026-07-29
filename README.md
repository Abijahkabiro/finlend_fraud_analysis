# FinLend Solutions End-to-End Fraud Analytics

Designed and delivered an end-to-end Business Intelligence solution that transformed 250,000 payment transactions into executive insights on fraud exposure, operational risk, and control opportunities. Built the solution using SQL Server, dimensional modelling, and Power BI to help business leaders understand where fraud occurs, which customer and merchant segments drive losses, and which risk indicators require immediate attention.

Focused on enabling better business decisions rather than building a fraud detection model. Used data profiling, analytical modelling, and executive reporting to provide decision-makers with the visibility needed to prioritize fraud mitigation based on evidence instead of assumptions.

**Author:** Abijah Kabiro | Business Intelligence Analyst | Nairobi, Kenya

**Technology Stack:** SQL Server • SSMS • Power BI • DAX • Power Query

**Dataset:** Synthetic, AI-assisted dataset containing 250,000 payment transactions across eight African markets. Designed the dataset to replicate realistic transaction behaviour, operational data quality issues, and fraud patterns commonly encountered within digital payment platforms.

**Project Focus:** Business Intelligence • Fraud Analytics • Data Quality • Operational Risk • Executive Reporting

---

## Business Context

FinLend Solutions is a fictional digital payments company operating across eight African markets: Kenya, Nigeria, Ghana, South Africa, Egypt, Tanzania, Uganda, and Rwanda. The platform supports peer-to-peer transfers, merchant payments, and mobile wallet transactions.

As transaction volumes expanded, fraud-related losses increased by approximately 40% year over year. Although leadership could measure the financial impact, they lacked visibility into where fraud was concentrated, which customer and merchant segments generated the greatest exposure, and which operational controls would deliver the highest business impact.

Without this visibility, fraud prevention efforts risk becoming reactive, costly, and unnecessarily restrictive for legitimate customers.

Built this analytical solution to bridge that gap by transforming raw transaction data into actionable business intelligence. Rather than predicting fraud, the solution enables decision-makers to prioritize risk, monitor operational performance, and implement targeted fraud mitigation strategies supported by evidence.

---

## About the Dataset

Created FinLend Solutions as a fictional organisation and used a synthetic dataset to simulate a realistic fintech environment.

Because production fraud data is typically restricted for privacy, regulatory, and commercial reasons, generated an AI-assisted dataset that mirrors common transaction patterns, operational data quality challenges, and fraud behaviours found in digital payment platforms.

Intentionally introduced missing values, duplicate records, inconsistent country labels, placeholder information, and invalid transactions to replicate the data quality issues Business Intelligence teams routinely address before meaningful analysis can begin.

---

## Business Objectives

Designed the analytical solution to answer four strategic business questions that support fraud management and operational decision-making.

### 1. Fraud Exposure

Determine where fraud is occurring across the business.

- Which payment methods exhibit the highest fraud rates?
- Which merchant categories generate the greatest fraud exposure?
- Which countries and cross-border payment corridors present elevated risk?
- During which hours of the day does fraud concentrate?

### 2. Customer and Merchant Risk

Identify who contributes most to fraud losses.

- Which merchants account for the highest fraud value?
- Which customers generate disproportionate financial exposure?
- How does customer tenure influence fraud risk?
- Does Know Your Customer (KYC) verification reduce fraud?

### 3. Operational Risk Indicators

Identify behaviours that consistently precede fraudulent transactions.

- Does an IP country mismatch increase fraud risk?
- Are newly registered customers more susceptible to fraud?
- Do transaction velocity spikes indicate coordinated fraud activity?

### 4. Executive Performance Monitoring

Measure the scale and direction of fraud over time.

- What is the organisation's overall fraud rate?
- How much revenue is lost to fraudulent transactions?
- Is fraud increasing over time?
- Which business segments contribute the largest share of fraud losses?

---

## Business Value

Delivered a Business Intelligence solution that enables stakeholders to:

- Monitor fraud performance through executive-level KPIs.
- Prioritize fraud investigations using customer and merchant risk profiles.
- Identify high-risk payment corridors requiring additional controls.
- Measure the financial impact of fraud across products and markets.
- Detect operational weaknesses such as IP-country mismatches and high-risk customer onboarding patterns.
- Support evidence-based fraud mitigation strategies without introducing unnecessary friction for legitimate customers.

---
## Solution Architecture

I designed the solution as a structured Business Intelligence workflow that prioritizes data quality, analytical consistency, and scalable reporting.

```text
Raw CSV Files
      │
      ▼
SQL Server Staging Layer
      │
      ▼
Data Quality Profiling
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
Executive Dashboard
```

Each stage builds on the previous one, creating an auditable analytics pipeline that preserves raw source data while delivering trusted business insights for decision-makers.

---

## Phase 1: Data Ingestion and Staging

I created a SQL Server staging layer to preserve the raw source files before applying any business transformations.

Rather than loading directly into typed tables, I staged all source columns as `NVARCHAR` to ensure inconsistent values could be ingested without causing ETL failures. This approach allowed me to measure data quality issues before deciding how to resolve them.

The four source datasets were loaded using **BULK INSERT** and validated against expected record counts.

| Dataset | Records |
|---|---:|
| Transactions | 250,000 |
| Customers | 15,000 |
| Merchants | 1,500 |
| Geography | 8 |

The staging layer provided an auditable foundation for profiling, cleansing, and downstream analytical modeling.

---

## Phase 2: Data Quality Profiling

Before transforming the data, I profiled the dataset to establish a measurable baseline for data quality.

Rather than correcting issues immediately, I identified, quantified, and documented every issue to ensure subsequent transformations were driven by evidence instead of assumptions.

| Quality Check | Finding |
|---|---|
| Missing values | 10,005 missing device IDs, 7,507 missing IP countries, 2,505 missing currency values |
| Country standardization | Multiple country variations caused by inconsistent casing, abbreviations, and whitespace |
| Invalid amounts | 405 transactions contained zero or negative values |
| Future timestamps | 60 records contained identical future timestamps |
| Duplicate transactions | 5,000 duplicate records across 2,500 duplicate groups |
| Placeholder emails | 90 records contained invalid placeholder email values |

Profiling first ensured every cleaning decision was measurable, traceable, and aligned with the analytical objectives.

---

## Phase 3: Data Transformation and Validation

I transformed the staging tables into a dimensional model optimized for reporting and business analysis.

Dimension tables were standardized first to establish trusted reference data before loading the transaction fact table.

The transformation pipeline included:

- `TRY_CONVERT()` for safe type conversion
- `CASE` expressions for business standardization rules
- `NULLIF()` for controlled null handling
- `ROW_NUMBER()` for duplicate identification and removal

After transformation, I validated the analytical model to confirm data integrity.

| Validation | Result |
|---|---:|
| Clean transactions | 247,040 |
| Standardized countries | 8 |
| Payment methods | 5 |
| Remaining duplicates | 0 |
| Orphaned customer relationships | 0 |
| Orphaned merchant relationships | 0 |

Rather than removing customers with invalid email addresses, I introduced an `is_valid_email` indicator. This preserved transaction history while making data quality issues visible for future remediation.

---

## Phase 4: Business Analysis

With the analytical model validated, I focused on answering the business questions that motivated the project.

The SQL analysis examined fraud across customer behavior, merchant performance, geography, and transaction activity using:

- Multi-table joins
- Common Table Expressions (CTEs)
- Window functions
- Ranking functions
- Time-series analysis
- Customer tenure segmentation
- Fraud rate calculations
- Merchant risk scoring
- Geographic corridor analysis
- Transaction velocity detection

Every analytical query was developed to support a specific business decision rather than simply producing technical outputs.

---

## Phase 5: SQL Performance Optimization

After completing the analytical model, I evaluated query performance to ensure the solution could scale efficiently.

The baseline query generated:

- Logical reads: 4,368
- CPU time: 172 ms
- Elapsed time: 213 ms

To improve performance, I implemented:

- A clustered index
- Four nonclustered indexes
- A covering index on `transaction_timestamp`
- A window-function rewrite replacing an inefficient correlated subquery

The optimized solution achieved:

| Metric | Before | After | Improvement |
|---|---:|---:|---:|
| Logical reads | 4,368 | 658 | **85% reduction** |
| CPU time | 172 ms | 94 ms | **45% faster** |
| Elapsed time | 213 ms | 116 ms | **46% faster** |

The optimization reinforced an important BI principle: performance improvements only become meaningful when measured against a baseline.

---

## Phase 6: Executive Reporting

I translated the analytical model into a five-page Power BI reporting solution built on a star schema.

The semantic model consists of:

- One fact table
- Four dimension tables
- DAX measures
- Row-Level Security (RLS)

Each dashboard page answers a specific business question.

1. Executive Overview
2. Fraud Trends
3. Merchant Risk
4. Geographic Analysis
5. Customer Risk

Rather than displaying every available metric, the dashboard focuses on helping decision-makers understand where fraud is increasing, which business segments carry the greatest exposure, and where intervention should be prioritized.

# Executive Insights

The analysis produced seven insights that explain where fraud exposure is concentrated and where FinLend should prioritize monitoring, controls, and investigative effort.

---

## 1. Fraud Exposure Increased by 39%

Fraud rate increased from **2.39% in Q1** to **3.32% in Q4**, representing a **39% increase** over the reporting period.

Across **$23.87M** in transaction value, the analysis identified **$917.58K** in confirmed fraudulent transactions.

The increase demonstrated that fraud exposure was accelerating rather than remaining stable, making trend analysis the starting point for the remainder of the investigation.

**Business implication:** Executive reporting should monitor fraud rate as a leading KPI, with quarterly reviews focused on identifying the operational drivers behind sustained increases.

---

## 2. Fraud Was Concentrated in a Small Number of Merchant Categories

Fraud exposure was not evenly distributed across merchants.

| Merchant Category | Fraud Rate |
|-------------------|-----------:|
| Crypto Exchange | **10.12%** |
| Gift Cards | **8.46%** |
| Betting | **7.37%** |
| Gaming | **6.90%** |

For comparison, the overall platform fraud rate was **2.93%**, while Groceries (**1.44%**) and Utilities (**1.21%**) remained comparatively low.

**Business implication:** Fraud controls should be applied proportionally to merchant risk. Higher-risk categories warrant enhanced monitoring and verification, while lower-risk merchants can operate with less customer friction.

---

## 3. Fraud Exposure Was Highest During Customer Onboarding

Customer tenure emerged as one of the strongest predictors of fraud.

| Account Age | Fraud Rate |
|-------------|-----------:|
| Under 30 Days | **6.23%** |
| 30–90 Days | **3.69%** |
| 90–365 Days | **2.24%** |
| Over 1 Year | **2.41%** |

Fraud exposure declined sharply after the first month before stabilizing.

**Business implication:** The onboarding period presents the highest operational risk. Stronger identity verification, lower transaction limits, and enhanced monitoring during the first 30 days would likely reduce fraud exposure.

---

## 4. IP Country Mismatch Was a High-Value Behavioural Risk Signal

Transactions where the IP country differed from the transaction country recorded a **6.49% fraud rate**, compared with **2.75%** where both locations matched.

Location mismatches do not automatically indicate fraud, but the relationship was strong enough to justify incorporating the signal into a broader risk assessment framework.

**Business implication:** IP-country mismatch should contribute to fraud risk scoring alongside other behavioural indicators instead of acting as a standalone blocking rule.

---

## 5. Overnight Transactions Carried Elevated Fraud Risk

Transactions processed between **12:00 AM and 5:00 AM** recorded a **5.59% fraud rate**, while daytime activity remained between **2.74%** and **2.99%**.

The concentration of fraud during overnight hours suggests elevated risk outside typical customer activity patterns.

**Business implication:** Transaction time should be incorporated into real-time fraud monitoring and used to trigger additional verification for higher-risk transactions.

---

## 6. Cross-Border Payment Corridors Revealed Stronger Patterns Than Country-Level Reporting

Country-level fraud rates remained relatively consistent across all eight markets.

However, analysing payment corridors revealed significantly stronger concentrations of fraud.

| Transaction Corridor | Fraud Rate |
|----------------------|-----------:|
| Tanzania → Rwanda | **10.29%** |
| Rwanda → Ghana | **10.09%** |
| Egypt → Ghana | **8.65%** |

Analysing corridors changed the business question from *"Which country has the highest fraud rate?"* to *"Which payment routes carry the greatest fraud exposure?"*

**Business implication:** Monitoring high-risk transaction corridors enables more targeted fraud controls while avoiding unnecessary friction across lower-risk markets.

---

## 7. Multiple Independent Risk Indicators Identified the Same Customer

Customer **CUST112663** consistently appeared across multiple analytical investigations.

- 82 total transactions
- 37 confirmed fraud transactions
- 45.12% individual fraud rate
- Four high-velocity transaction bursts within 24 hours

The account was independently identified by both the highest fraud value analysis and the transaction velocity analysis.

**Business implication:** When multiple analytical techniques identify the same customer, confidence in the finding increases substantially. In a production environment, this combination of signals would justify immediate investigation or account review.

---

# Dimensional Data Model

I designed the reporting solution using a star schema to support scalable analytics, simplify DAX calculations, and provide consistent filtering across the Power BI semantic model.

| Table | Purpose | Records |
|---------|---------|---------:|
| **fact_transactions** | Stores transaction-level events | 247,040 |
| **dim_customers** | Customer attributes | 15,000 |
| **dim_merchants** | Merchant attributes | 1,500 |
| **dim_geography** | Geographic reference data | 8 |
| **dim_date** | Calendar dimension | 366 |

The model follows dimensional modelling best practices using one-to-many, single-direction relationships from each dimension to the transaction fact table. This design reduces model ambiguity, improves query performance, and provides predictable filter propagation throughout the reporting solution.

Transaction values are stored as **USD equivalents** to support consistent cross-market reporting. The original transaction currency is retained separately within the `local_currency` attribute to preserve business context while enabling standardized financial analysis across all operating markets.

# Dashboard Preview

## Page 1: Executive Overview

I designed the Executive Overview for business leaders who need an immediate view of fraud performance.

The dashboard presents executive KPIs including fraud rate, transaction value, fraud value, chargeback value, monthly fraud trends, and payment channel performance.

Its primary purpose is to help decision-makers determine whether fraud exposure is increasing and identify areas requiring further investigation.

![Executive Overview](PowerBI/Executive_Overview.png)

---

## Page 2: Fraud Trends

This page explores behavioural patterns associated with fraudulent activity.

The analysis examines fraud rates by payment method, transaction time, IP-country mismatch, and fraud type to identify recurring indicators of elevated fraud exposure.

The objective is to support earlier intervention by highlighting behavioural signals that can strengthen fraud monitoring.

![Fraud Trends](PowerBI/Fraud_Trends.png)

---

## Page 3: Merchant Risk

This dashboard evaluates fraud exposure across merchant segments.

It compares fraud rates, transaction volumes, merchant rankings, and overall merchant performance to identify businesses generating disproportionate fraud losses.

The analysis enables risk teams to prioritise monitoring resources where they will have the greatest business impact.

![Merchant Risk](PowerBI/Merchant_Risk.png)

---

## Page 4: Geographic Analysis

This page examines fraud exposure across operating markets and cross-border payment corridors.

While country-level reporting provides a broad view of geographic performance, corridor analysis reveals the transaction routes responsible for the highest fraud exposure.

The dashboard enables business stakeholders to focus fraud controls on high-risk payment flows rather than applying uniform controls across entire markets.

![Geographic Analysis](PowerBI/Geographic_Analysis.png)

---

## Page 5: Customer Risk

This dashboard focuses on customer behaviour and fraud exposure throughout the customer lifecycle.

The analysis includes fraud rates by account tenure, KYC status, customer fraud value, and transaction velocity to identify accounts exhibiting multiple risk indicators.

The page supports investigation teams by prioritising customers requiring immediate review.

![Customer Risk](PowerBI/Customer_Profiles.png)

---

# SQL Performance Optimization

Performance testing was conducted before and after optimization to quantify the impact of indexing and query tuning.

| Metric | Before | After | Improvement |
|---|---:|---:|---:|
| Logical Reads | 4,368 | 658 | **85% reduction** |
| CPU Time | 172 ms | 94 ms | **45% faster** |
| Elapsed Time | 213 ms | 116 ms | **46% faster** |

In addition to the indexing strategy, I replaced an inefficient correlated subquery with a window function, eliminating 247,040 repeated executions in favour of a single-pass calculation.

The optimization demonstrated the importance of establishing performance baselines before implementing tuning strategies.

---

# Row-Level Security

To demonstrate enterprise reporting practices, I implemented Row-Level Security (RLS) within the Power BI semantic model.

Four regional security roles were created:

- East Africa
- West Africa
- Southern Africa
- North Africa

Each role filters the Geography dimension, with security automatically propagating through the star schema to the transaction fact table.

This approach enables multiple business teams to share a single reporting solution while restricting each user to the data relevant to their assigned region.

**Example**

Viewing the report as the **East Africa** role reduces visible transaction value from **$23.87M** globally to **$9.04M**, exposing only transactions from Kenya, Tanzania, Uganda, and Rwanda.

![Row-Level Security](PowerBI/rls_test2.png)

---

# Business Recommendations

The analysis identified five opportunities to reduce fraud exposure while maintaining a positive customer experience.

## 1. Prioritise High-Risk Merchant Categories

Crypto Exchange (10.12%), Gift Cards (8.46%), Betting (7.37%), and Gaming (6.90%) recorded fraud rates well above the platform average of 2.93%.

**Recommendation:** Apply enhanced monitoring, transaction limits, and additional verification to these merchant categories instead of introducing platform-wide restrictions.

---

## 2. Strengthen Controls During Customer Onboarding

Accounts less than 30 days old recorded a fraud rate of **6.23%**, almost three times higher than mature accounts.

**Recommendation:** Strengthen onboarding controls through mandatory KYC verification, lower transaction limits, and enhanced monitoring during the first 30 days of the customer lifecycle.

---

## 3. Incorporate Behavioural Risk Signals into Fraud Scoring

Transactions involving IP-country mismatches (6.49%) and overnight activity (5.59%) consistently demonstrated elevated fraud exposure.

**Recommendation:** Introduce adaptive verification when multiple behavioural risk indicators occur simultaneously, such as geographic mismatch, unusual transaction timing, high-value transactions, and recently created accounts.

---

## 4. Monitor High-Risk Cross-Border Payment Corridors

Fraud was concentrated within specific transaction routes rather than individual countries.

| Corridor | Fraud Rate |
|---|---:|
| Tanzania → Rwanda | **10.29%** |
| Rwanda → Ghana | **10.09%** |
| Egypt → Ghana | **8.65%** |

**Recommendation:** Develop monitoring rules around high-risk payment corridors to improve fraud detection while minimising unnecessary friction across lower-risk markets.

---

## 5. Prioritise Customers Exhibiting Multiple Risk Indicators

Customer **CUST112663** was independently identified by fraud value analysis and transaction velocity detection.

**Recommendation:** Develop a customer risk scoring framework combining fraud history, transaction velocity, geographic anomalies, account tenure, and KYC status to prioritise investigations.

---

# Data Quality Management

Data quality management formed a core component of the analytical solution rather than a preprocessing activity.

Six categories of issues were identified, measured, and resolved before analysis.

| Issue | Volume | Root Cause | Resolution |
|---|---:|---|---|
| Duplicate transactions | 2,500 pairs | Payment retries | `ROW_NUMBER()` deduplication |
| Country inconsistencies | Multiple formats | Mixed naming conventions | Standardisation using business mapping rules |
| Payment method variations | Multiple formats | Legacy and manual entry | Text standardisation |
| Invalid transaction amounts | 405 | Data entry and system errors | Removed invalid transactions |
| Future timestamps | 60 | System timestamp anomaly | Removed out-of-period records |
| Placeholder emails | 90 | Test and incomplete accounts | Flagged using `is_valid_email` |

Every transformation was validated using before-and-after record counts to ensure changes were measurable, traceable, and reproducible.

The final analytical model contained:

- **247,040** validated transactions
- **8** standardised countries
- **5** payment methods
- **0** duplicate records
- **0** orphaned relationships

# Business Intelligence Capabilities Demonstrated

This project demonstrates practical experience across the end-to-end Business Intelligence lifecycle.

- Business problem definition and requirements analysis
- Data ingestion and staging architecture
- Data quality profiling and validation
- Data transformation and standardization
- Dimensional modeling (Star Schema)
- SQL analytics and performance optimization
- KPI design and executive reporting
- Power BI semantic modeling and DAX
- Row-Level Security (RLS)
- Dashboard design for decision support
- Business insight generation
- Executive recommendations based on analytical evidence

# Project Outcomes

The completed solution enabled FinLend leadership to:

- Identify the merchant categories generating the highest fraud exposure.
- Prioritize customer segments requiring enhanced monitoring.
- Detect behavioral indicators suitable for fraud risk scoring.
- Focus fraud controls on high-risk transaction corridors rather than entire markets.
- Monitor fraud trends through a scalable Power BI reporting solution.
- Support fraud mitigation decisions using trusted analytical evidence.

# Technical Implementation Notes

Developing the solution required resolving several technical challenges across SQL Server and Power BI.

| Challenge | Resolution |
|------------|------------|
| Loading CSV files into SQL Server | Configured BULK INSERT paths and local file access to create a reliable staging process. |
| SQL Server connection in Power BI | Updated connection settings to the correct SQL Server instance. |
| Fraud rate calculations | Rebuilt DAX measures using boolean filters and VAR-based calculations to ensure accurate KPI reporting. |
| Date modeling | Created a dedicated date dimension and configured relationships to support time intelligence. |
| Month sorting | Used a numeric month column to ensure chronological reporting. |
| Query performance | Added clustered, nonclustered, and covering indexes and rewrote inefficient queries using window functions, reducing logical reads by 85% and execution time by 46%. |

These implementation decisions improved data quality, report accuracy, and overall solution performance.

---

# Running the Project

### SQL Server

1. Create a database named **FinLend**.
2. Place the four CSV files in a location accessible by SQL Server.
3. Open `SQL/FinLend.sql`.
4. Update the `BULK INSERT` file paths.
5. Execute the script sequentially.

### Power BI

1. Open `PowerBI/FinLend_fraud_analysis.pbix`.
2. Update the SQL Server connection.
3. Refresh the dataset.
4. Navigate through the five dashboard pages.
5. Test Row-Level Security using **Modeling → View As**.

---

# Repository Structure

```text
finlend/
│
├── README.md
├── SQL/
├── PowerBI/
├── fact_transactions.csv
├── dim_customers.csv
├── dim_merchants.csv
└── dim_geography.csv
```

---

# Related Content

A detailed walkthrough of the project, including the business context, analytical approach, SQL implementation, Power BI development, and business recommendations, is available on Medium.

**Read the full article:** https://medium.com/@abijahkabiro/fraud-was-increasing-business-intelligence-revealed-where-finlend-was-most-exposed-401373f9a1d1

---

# About the Author

I'm **Abijah Kabiro**, a Business Intelligence Analyst who designs end-to-end analytical solutions that transform operational data into trusted business insights. My work combines SQL Server, Python, dimensional modeling, and Power BI to support reporting, performance improvement, and evidence-based decision-making.

I specialize in the complete Business Intelligence lifecycle from understanding business problems and preparing data to designing analytical models, developing executive dashboards, and delivering recommendations that improve business performance.

## Connect

- **Portfolio:** https://abijahkabiro.github.io
- **LinkedIn:** https://linkedin.com/in/abijahkabiro
- **GitHub:** https://github.com/Abijahkabiro
- **Medium:** https://medium.com/@abijahkabiro