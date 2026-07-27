--Step 1: Create and stage the database
---Create the Finlend Database
CREATE DATABASE FinLend;
GO
---Using Finlend Database
USE FinLend;
GO
-- Drop the staging table if it already exists, then recreate it to ensure a clean load every time the script is executed.
IF OBJECT_ID('stg_transactions') IS NOT NULL DROP TABLE stg_transactions;
CREATE TABLE stg_transactions (
    transaction_id        NVARCHAR(50),
    customer_id           NVARCHAR(50),
    merchant_id           NVARCHAR(50),
    transaction_timestamp NVARCHAR(50),
    amount                NVARCHAR(50),
    local_currency        NVARCHAR(10),
    payment_method        NVARCHAR(50),
    transaction_type      NVARCHAR(50),
    channel               NVARCHAR(50),
    transaction_country   NVARCHAR(50),
    ip_country            NVARCHAR(50),
    device_id             NVARCHAR(50),
    status                NVARCHAR(50),
    is_fraud              NVARCHAR(10),
    is_chargeback         NVARCHAR(10),
    fraud_type            NVARCHAR(50)
);
GO
USE FinLend;
GO

-- Same idea as the transaction staging table. Three more landing pads. All text.
-- Customers, merchants, geography. Each column order matches its CSV.

IF OBJECT_ID('stg_customers') IS NOT NULL DROP TABLE stg_customers;
CREATE TABLE stg_customers (
    customer_id      NVARCHAR(50),   -- the key. links to transactions later
    first_name       NVARCHAR(50),
    last_name        NVARCHAR(50),
    email            NVARCHAR(150),  -- some are junk. test@test.com and friends
    signup_date      NVARCHAR(50),   -- text for now. we date it in cleaning
    home_country     NVARCHAR(50),
    customer_segment NVARCHAR(50),
    kyc_status       NVARCHAR(50)    -- verified, pending, unverified
);

IF OBJECT_ID('stg_merchants') IS NOT NULL DROP TABLE stg_merchants;
CREATE TABLE stg_merchants (
    merchant_id       NVARCHAR(50),  -- the key. links to transactions later
    merchant_name     NVARCHAR(120),
    merchant_category NVARCHAR(50),  -- this drives most of the fraud story
    merchant_country  NVARCHAR(50),
    onboarding_date   NVARCHAR(50)   -- text for now
);

IF OBJECT_ID('stg_geography') IS NOT NULL DROP TABLE stg_geography;
CREATE TABLE stg_geography (
    country_id     NVARCHAR(10),
    country_name   NVARCHAR(50),     -- the clean label we map messy names to
    country_code   NVARCHAR(10),
    region         NVARCHAR(50),     -- East, West, Southern, North Africa
    local_currency NVARCHAR(10)
);
GO

USE FinLend;
GO

-- Pour each CSV into its staging table. Read off disk. Skip the header.
-- Files live in my OneDrive finlend folder.

BULK INSERT stg_transactions
FROM 'C:\Users\abija\OneDrive\Documents\DATA ANALYTICS\DATA PROJECTS\finlend\fact_transactions.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);

BULK INSERT stg_customers
FROM 'C:\Users\abija\OneDrive\Documents\DATA ANALYTICS\DATA PROJECTS\finlend\dim_customers.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);

BULK INSERT stg_merchants
FROM 'C:\Users\abija\OneDrive\Documents\DATA ANALYTICS\DATA PROJECTS\finlend\dim_merchants.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);

BULK INSERT stg_geography
FROM 'C:\Users\abija\OneDrive\Documents\DATA ANALYTICS\DATA PROJECTS\finlend\dim_geography.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);
GO
-- Quick headcount. Did every CSV actually land in its table? Here I am counting the rows in each staging table.
-- The numbers must match what I loaded. If one reads 0, that file did not load.

SELECT 'transactions' AS tbl, COUNT(*) AS rows_loaded FROM stg_transactions   -- want 250000
UNION ALL SELECT 'customers',  COUNT(*) FROM stg_customers                     -- want 15000
UNION ALL SELECT 'merchants',  COUNT(*) FROM stg_merchants                     -- want 1500
UNION ALL SELECT 'geography',  COUNT(*) FROM stg_geography;                    -- want 8
GO
--Step 2:Understand the problem, the data, and the questions
-- STEP 3: Data cleaning and profiling
-- Profile first, clean second. Measure the dirt before I touch it.

-- Step 3a. Data Profiling

-- CHECK: null values
-- Looking for missing data in the optional columns.
-- These gaps will not stop the analysis, but I want their size before I clean.
-- Here I count the blanks and nulls in each column that is allowed to be empty.

SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN device_id      IS NULL OR device_id      = '' THEN 1 ELSE 0 END) AS missing_device,
    SUM(CASE WHEN ip_country     IS NULL OR ip_country     = '' THEN 1 ELSE 0 END) AS missing_ip,
    SUM(CASE WHEN local_currency IS NULL OR local_currency = '' THEN 1 ELSE 0 END) AS missing_currency
FROM stg_transactions;


-- CHECK: data consistency / standardization
-- Looking for inconsistent values in transaction_country.
-- One country should have one spelling. Here I list every spelling and how often it appears.
-- I expect Kenya, KENYA, kenya and KE as separate rows. That split is what I will standardize.

SELECT
    transaction_country,
    COUNT(*) AS times_seen
FROM stg_transactions
GROUP BY transaction_country
ORDER BY transaction_country;

-- CHECK: Detecting Non-Numeric and Out-of-Range Transaction Amounts i.e valid range / domain check
-- Looking for amounts that break the rules. An amount should be a positive number.
-- Here I count how many are non-numeric, and how many are zero or negative.
-- TRY_CONVERT returns NULL when the text is not a real number, so I catch those too.

SELECT
    SUM(CASE WHEN TRY_CONVERT(DECIMAL(12,2), amount) IS NULL THEN 1 ELSE 0 END) AS non_numeric,
    SUM(CASE WHEN TRY_CONVERT(DECIMAL(12,2), amount) <= 0   THEN 1 ELSE 0 END) AS zero_or_negative
FROM stg_transactions;

-- CHECK: date validity
-- Looking for timestamps that should not exist. No transaction can happen in the future.
-- My data ends May 2026, so anything later is a clock or timezone bug.
-- Here I count how many rows fall after the window, and I peek at a few.

SELECT COUNT(*) AS future_dated
FROM stg_transactions
WHERE TRY_CONVERT(DATETIME2, transaction_timestamp) > '2026-06-01';

-- Peek at the actual future dates so I can see the bug, not just count it
SELECT TOP 10 transaction_id, transaction_timestamp
FROM stg_transactions
WHERE TRY_CONVERT(DATETIME2, transaction_timestamp) > '2026-06-01'
ORDER BY transaction_timestamp DESC;

-- CHECK: duplicate detection
-- Looking for transactions that were recorded more than once.
-- A real duplicate repeats across the business fields, not just the id.
-- Here I count rows that share the same id, customer, merchant, time and amount.
-- COUNT(*) OVER (PARTITION BY ...) tags each row with how many copies of it exist.

WITH dup AS (
    SELECT
        COUNT(*) OVER (
            PARTITION BY transaction_id, customer_id, merchant_id,
                         transaction_timestamp, amount
        ) AS copies
    FROM stg_transactions
)
SELECT COUNT(*) AS rows_in_duplicate_groups
FROM dup
WHERE copies > 1;

-- CHECK: validity / pattern check
-- Looking for fake emails left in the customer table. Test accounts that reached production.
-- A real email has something@something.domain. These placeholders do not.
-- Here I list the junk values and how many customers carry each.

SELECT
    email,
    COUNT(*) AS times_seen
FROM stg_customers
WHERE email NOT LIKE '%_@_%._%'
   OR email IN ('test@test.com','na','none','xxx@xxx.com','placeholder@finlend.io')
GROUP BY email
ORDER BY times_seen DESC;

-- Step 3b:Data Cleaning: Cleaning. Dimension first, smallest first.
-- dim_geography is my clean country reference. 8 rows, already tidy.
-- I just give it real types and a primary key, then move the rows across.

-- DROP and rebuild so this script always re-runs clean
IF OBJECT_ID('dim_geography') IS NOT NULL DROP TABLE dim_geography;
CREATE TABLE dim_geography (
    country_id     INT PRIMARY KEY,        -- the unique fingerprint of each country
    country_name   VARCHAR(20) NOT NULL,   -- the canonical spelling I map messy names to
    country_code   CHAR(2)     NOT NULL,   -- two letter code, always exactly 2 chars
    region         VARCHAR(20) NOT NULL,   -- East, West, Southern, North Africa
    local_currency CHAR(3)     NOT NULL    -- three letter currency code
);

-- Move staging rows into the clean table. Convert the id from text to a real number.
INSERT INTO dim_geography
SELECT
    TRY_CONVERT(INT, country_id),          -- text to integer
    country_name,
    country_code,
    region,
    local_currency
FROM stg_geography;

-- CHECK: confirm all 8 landed
SELECT * FROM dim_geography ORDER BY country_id;

-- Data Cleaning: dim_customers
-- Two things beyond a simple type conversion here.
-- 1. signup_date becomes a real DATE so I can calculate customer tenure in the analysis.
-- 2. is_valid_email flags junk emails with a 0 instead of deleting the customer.
-- Why not delete: a customer with a fake email still made real transactions.
-- Delete them and I orphan their transaction history and break the customer join.

IF OBJECT_ID('dim_customers') IS NOT NULL DROP TABLE dim_customers;
CREATE TABLE dim_customers (
    customer_id      VARCHAR(20) PRIMARY KEY,
    first_name       VARCHAR(50),
    last_name        VARCHAR(50),
    email            VARCHAR(120),
    is_valid_email   BIT,           -- 1 = real email, 0 = junk. Flag, do not delete.
    signup_date      DATE,          -- real date now. used for tenure in analysis.
    home_country     VARCHAR(20),
    customer_segment VARCHAR(15),
    kyc_status       VARCHAR(15)
);

INSERT INTO dim_customers
SELECT
    customer_id,
    first_name,
    last_name,
    email,
    -- is_valid_email: 1 if it looks like a real email and is not a known placeholder
    CASE WHEN email LIKE '%_@_%._%'
              AND email NOT IN ('test@test.com','xxx@xxx.com','placeholder@finlend.io')
         THEN 1 ELSE 0 END,
    TRY_CONVERT(DATE, signup_date),
    home_country,
    customer_segment,
    kyc_status
FROM stg_customers;

-- CHECK: see the flag working. I want both a 1 and a 0 visible in the result.
SELECT TOP 20 customer_id, email, is_valid_email, signup_date
FROM dim_customers
ORDER BY is_valid_email;

-- Quick confirm. How many valid vs junk?
SELECT is_valid_email, COUNT(*) AS customers
FROM dim_customers
GROUP BY is_valid_email;

-- Data Cleaning: dim_merchants
-- Cleanest dimension. No flags needed, no messy labels.
-- I just convert onboarding_date from text to a real DATE and move everything across.

IF OBJECT_ID('dim_merchants') IS NOT NULL DROP TABLE dim_merchants;
CREATE TABLE dim_merchants (
    merchant_id       VARCHAR(20) PRIMARY KEY,
    merchant_name     VARCHAR(80),
    merchant_category VARCHAR(30),
    merchant_country  VARCHAR(20),
    onboarding_date   DATE
);

INSERT INTO dim_merchants
SELECT
    merchant_id,
    merchant_name,
    merchant_category,
    merchant_country,
    TRY_CONVERT(DATE, onboarding_date)
FROM stg_merchants;

-- CHECK: row count. 
SELECT COUNT(*) AS merchant_count FROM dim_merchants;

-- Data Cleaning: fact_transactions
-- The big one. All 6 issues fixed in one CTE called "typed".
-- typed does the conversion and standardization. The outer WHERE does the filtering.

IF OBJECT_ID('fact_transactions') IS NOT NULL DROP TABLE fact_transactions;
CREATE TABLE fact_transactions (
    transaction_id        VARCHAR(20),
    customer_id           VARCHAR(20),
    merchant_id           VARCHAR(20),
    transaction_timestamp DATETIME2,
    amount                DECIMAL(12,2),
    local_currency        CHAR(3)      NULL,
    payment_method        VARCHAR(30),
    transaction_type      VARCHAR(15),
    channel               VARCHAR(15),
    transaction_country   VARCHAR(20),
    ip_country            VARCHAR(20)  NULL,
    device_id             VARCHAR(20)  NULL,
    status                VARCHAR(15),
    is_fraud              BIT,
    is_chargeback         BIT,
    fraud_type            VARCHAR(30)  NULL
);

;WITH typed AS (
    SELECT
        transaction_id,
        customer_id,
        merchant_id,
        TRY_CONVERT(DATETIME2, transaction_timestamp)       AS ts,
        TRY_CONVERT(DECIMAL(12,2), amount)                  AS amt,
        NULLIF(local_currency, '')                          AS local_currency,

        -- Standardize payment_method: trim whitespace, map every variant to one clean label
        CASE LOWER(LTRIM(RTRIM(payment_method)))
            WHEN 'p2p transfer'     THEN 'P2P Transfer'
            WHEN 'merchant payment' THEN 'Merchant Payment'
            WHEN 'mobile wallet'    THEN 'Mobile Wallet'
            WHEN 'card payment'     THEN 'Card Payment'
            WHEN 'bank transfer'    THEN 'Bank Transfer'
            ELSE LTRIM(RTRIM(payment_method))
        END                                                 AS payment_method,

        transaction_type,
        channel,

        -- Standardize country labels to canonical names.
        -- UPPER + LTRIM + RTRIM handles case and whitespace before the CASE compares.
        -- This is why " Uganda" and "KENYA" and "KE" all map to the right name.
        CASE UPPER(LTRIM(RTRIM(transaction_country)))
            WHEN 'KENYA'        THEN 'Kenya'
            WHEN 'KE'           THEN 'Kenya'
            WHEN 'NIGERIA'      THEN 'Nigeria'
            WHEN 'NG'           THEN 'Nigeria'
            WHEN 'GHANA'        THEN 'Ghana'
            WHEN 'GH'           THEN 'Ghana'
            WHEN 'SOUTH AFRICA' THEN 'South Africa'
            WHEN 'RSA'          THEN 'South Africa'
            WHEN 'ZA'           THEN 'South Africa'
            WHEN 'EGYPT'        THEN 'Egypt'
            WHEN 'EG'           THEN 'Egypt'
            WHEN 'TANZANIA'     THEN 'Tanzania'
            WHEN 'TZ'           THEN 'Tanzania'
            WHEN 'UGANDA'       THEN 'Uganda'
            WHEN 'UG'           THEN 'Uganda'
            WHEN 'RWANDA'       THEN 'Rwanda'
            WHEN 'RW'           THEN 'Rwanda'
            ELSE LTRIM(RTRIM(transaction_country))
        END                                                 AS transaction_country,

        NULLIF(ip_country, '')                              AS ip_country,
        NULLIF(device_id, '')                               AS device_id,
        status,
        TRY_CONVERT(BIT, is_fraud)                          AS is_fraud,
        TRY_CONVERT(BIT, is_chargeback)                     AS is_chargeback,
        NULLIF(fraud_type, '')                              AS fraud_type,

        -- Deduplication. Number every copy of an identical business row.
        -- ORDER BY (SELECT NULL) because I do not care which copy I keep, they are identical.
        ROW_NUMBER() OVER (
            PARTITION BY transaction_id, customer_id, merchant_id,
                         transaction_timestamp, amount
            ORDER BY (SELECT NULL)
        ) AS rn

    FROM stg_transactions
)
INSERT INTO fact_transactions
SELECT
    transaction_id, customer_id, merchant_id, ts, amt, local_currency,
    payment_method, transaction_type, channel, transaction_country,
    ip_country, device_id, status, is_fraud, is_chargeback, fraud_type
FROM typed
WHERE rn = 1              -- drop exact duplicates, keep first copy only
  AND ts IS NOT NULL      -- drop rows where the date would not parse
  AND ts <= '2026-06-01'  -- drop future-dated rows
  AND amt IS NOT NULL     -- drop non-numeric amounts
  AND amt > 0;            -- drop zero and negative amounts
GO

-- CHECK: row count.
SELECT COUNT(*) AS rows_after_clean FROM fact_transactions;

-- CHECK: post-clean validation
-- Did the cleaning do what I said it would? Every number here must make sense.
-- This is my proof that the clean layer is trustworthy before I start analysing.

SELECT 'rows after clean'          AS check_name, COUNT(*)                            AS value FROM fact_transactions
UNION ALL
SELECT 'distinct countries',        COUNT(DISTINCT transaction_country)                FROM fact_transactions
-- want 8. One canonical spelling each.
UNION ALL
SELECT 'distinct payment methods',  COUNT(DISTINCT payment_method)                     FROM fact_transactions
-- want 5 clean values.
UNION ALL
SELECT 'remaining duplicate ids',   COUNT(*) - COUNT(DISTINCT transaction_id)          FROM fact_transactions
-- want 0.
UNION ALL
SELECT 'orphan customer fks',
    (SELECT COUNT(*) FROM fact_transactions f
       LEFT JOIN dim_customers c ON f.customer_id = c.customer_id
      WHERE c.customer_id IS NULL)
-- want 0. Every transaction must point to a real customer.
UNION ALL
SELECT 'orphan merchant fks',
    (SELECT COUNT(*) FROM fact_transactions f
       LEFT JOIN dim_merchants m ON f.merchant_id = m.merchant_id
      WHERE m.merchant_id IS NULL);
-- want 0. Every transaction must point to a real merchant.
GO

-- STEP 4: Analysis
-- EXECUTIVE OVERVIEW: headline numbers
-- Business question: how large is the fraud problem right now?
-- One row. The number that opens every conversation about this project.

SELECT
    COUNT(*)                                                    AS total_transactions,
    SUM(amount)                                                 AS total_value,
    SUM(CAST(is_fraud AS INT))                                  AS fraud_count,
    CAST(100.0 * SUM(CAST(is_fraud AS INT)) / COUNT(*)
         AS DECIMAL(5,2))                                       AS fraud_rate_pct,
    SUM(CASE WHEN is_fraud = 1 THEN amount ELSE 0 END)          AS fraud_value,
    SUM(CASE WHEN is_chargeback = 1 THEN amount ELSE 0 END)     AS chargeback_value
FROM fact_transactions;


-- EXECUTIVE OVERVIEW: monthly fraud trend
-- Business question: is fraud rising across the year?
-- Techniques: CTE, time series, running total, rolling average window function.

WITH monthly AS (
    -- First I collapse the fact table down to one row per month.
    -- This becomes the base I run the window functions over.
    SELECT
        DATEFROMPARTS(YEAR(transaction_timestamp), MONTH(transaction_timestamp), 1) AS month_start,
        COUNT(*)                                                AS txns,
        SUM(CAST(is_fraud AS INT))                              AS fraud_txns,
        SUM(CASE WHEN is_fraud = 1 THEN amount ELSE 0 END)      AS fraud_value
    FROM fact_transactions
    GROUP BY DATEFROMPARTS(YEAR(transaction_timestamp), MONTH(transaction_timestamp), 1)
)
SELECT
    month_start,
    txns,
    fraud_txns,
    CAST(100.0 * fraud_txns / txns AS DECIMAL(5,2))             AS fraud_rate_pct,
    -- Running total: cumulative fraud value growing across the year
    SUM(fraud_value) OVER (ORDER BY month_start)                AS cumulative_fraud_value,
    -- Rolling average: smooths monthly noise so the rising trend is clear
    AVG(CAST(100.0 * fraud_txns / txns AS DECIMAL(5,2)))
        OVER (ORDER BY month_start ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
                                                                AS fraud_rate_3mo_avg
FROM monthly
ORDER BY month_start;

-- EXECUTIVE OVERVIEW: first quarter vs last quarter
-- Business question: how much has fraud risen from start to end of the year?
-- Technique: CTE with ROW_NUMBER to identify first and last months.

WITH m AS (
    SELECT
        DATEFROMPARTS(YEAR(transaction_timestamp), MONTH(transaction_timestamp), 1) AS mth,
        100.0 * SUM(CAST(is_fraud AS INT)) / COUNT(*) AS rate
    FROM fact_transactions
    GROUP BY DATEFROMPARTS(YEAR(transaction_timestamp), MONTH(transaction_timestamp), 1)
),
ranked AS (
    SELECT mth, rate,
           ROW_NUMBER() OVER (ORDER BY mth)  AS rn,
           COUNT(*) OVER ()                  AS total
    FROM m
)
SELECT
    CAST(AVG(CASE WHEN rn <= 3 THEN rate END) AS DECIMAL(5,2))           AS first_qtr_avg_rate,
    CAST(AVG(CASE WHEN rn > total - 3 THEN rate END) AS DECIMAL(5,2))    AS last_qtr_avg_rate
FROM ranked;

-- FRAUD TRENDS: payment method and channel
-- Business question: which payment methods and channels carry the most fraud?
-- Technique: grouping, fraud rate calculation, sorting by risk.

SELECT
    payment_method,
    channel,
    COUNT(*)                                                         AS txns,
    SUM(CAST(is_fraud AS INT))                                       AS fraud_txns,
    CAST(100.0 * SUM(CAST(is_fraud AS INT)) / COUNT(*)
         AS DECIMAL(5,2))                                            AS fraud_rate_pct
FROM fact_transactions
GROUP BY payment_method, channel
ORDER BY fraud_rate_pct DESC;

-- FRAUD TRENDS: hourly clustering
-- Business question: what times of day cluster fraud?
-- I expect overnight hours 0 to 4 to show a higher rate than daytime.
-- Technique: DATEPART to extract hour, CASE to band into overnight vs daytime.

SELECT
    DATEPART(HOUR, transaction_timestamp)                            AS hour_of_day,
    COUNT(*)                                                         AS txns,
    SUM(CAST(is_fraud AS INT))                                       AS fraud_txns,
    CAST(100.0 * SUM(CAST(is_fraud AS INT)) / COUNT(*)
         AS DECIMAL(5,2))                                            AS fraud_rate_pct,
    CASE WHEN DATEPART(HOUR, transaction_timestamp) BETWEEN 0 AND 4
         THEN 'Overnight' ELSE 'Daytime' END                         AS window_band
FROM fact_transactions
GROUP BY DATEPART(HOUR, transaction_timestamp)
ORDER BY hour_of_day;

-- FRAUD TRENDS: impossible travel signal
-- Business question: does IP country diverging from transaction country raise fraud risk?
-- A real customer transacts where they are. A fraudster's IP often says otherwise.
-- Technique: CASE to flag mismatch, fraud rate comparison between the two groups.

SELECT
    CASE WHEN ip_country IS NOT NULL AND ip_country <> transaction_country
         THEN 'IP mismatch' ELSE 'IP aligned' END                    AS ip_signal,
    COUNT(*)                                                         AS txns,
    SUM(CAST(is_fraud AS INT))                                       AS fraud_txns,
    CAST(100.0 * SUM(CAST(is_fraud AS INT)) / COUNT(*)
         AS DECIMAL(5,2))                                            AS fraud_rate_pct
FROM fact_transactions
GROUP BY
    CASE WHEN ip_country IS NOT NULL AND ip_country <> transaction_country
         THEN 'IP mismatch' ELSE 'IP aligned' END;

-- FRAUD TRENDS: fraud type mix
-- Business question: what kinds of fraud are actually occurring at FinLend?
-- This tells the ops team what they are dealing with, not just how much.

SELECT
    fraud_type,
    COUNT(*)                                                         AS cases,
    SUM(amount)                                                      AS total_value,
    CAST(100.0 * COUNT(*) /
         SUM(COUNT(*)) OVER ()
         AS DECIMAL(5,2))                                            AS pct_of_fraud
FROM fact_transactions
WHERE is_fraud = 1
GROUP BY fraud_type
ORDER BY cases DESC;

-- MERCHANT RISK: category ranking
-- Business question: which merchant categories are most affected by fraud?
-- Technique: multi-table JOIN, fraud rate calculation, RANK window function.

SELECT
    m.merchant_category,
    COUNT(*)                                                         AS txns,
    SUM(CAST(f.is_fraud AS INT))                                     AS fraud_txns,
    CAST(100.0 * SUM(CAST(f.is_fraud AS INT)) / COUNT(*)
         AS DECIMAL(5,2))                                            AS fraud_rate_pct,
    RANK() OVER (
        ORDER BY 1.0 * SUM(CAST(f.is_fraud AS INT)) / COUNT(*) DESC
    )                                                                AS risk_rank
FROM fact_transactions f
JOIN dim_merchants m ON f.merchant_id = m.merchant_id
GROUP BY m.merchant_category
ORDER BY fraud_rate_pct DESC;

-- MERCHANT RISK: composite risk score for top 25 merchants
-- Business question: which specific merchants need controls first?
-- Technique: CTE, PERCENT_RANK window function, NTILE, minimum volume guard.
-- Score blends fraud rate (60%) and fraud value percentile (40%).
-- HAVING COUNT(*) >= 50 removes tiny merchants where rates are statistically noisy.

WITH merch AS (
    SELECT
        m.merchant_id,
        m.merchant_name,
        m.merchant_category,
        COUNT(*)                                                AS txns,
        SUM(CAST(f.is_fraud AS INT))                            AS fraud_txns,
        100.0 * SUM(CAST(f.is_fraud AS INT)) / COUNT(*)         AS fraud_rate,
        SUM(CASE WHEN f.is_chargeback = 1 THEN 1 ELSE 0 END)   AS chargebacks,
        SUM(CASE WHEN f.is_fraud = 1 THEN f.amount ELSE 0 END)  AS fraud_value
    FROM fact_transactions f
    JOIN dim_merchants m ON f.merchant_id = m.merchant_id
    GROUP BY m.merchant_id, m.merchant_name, m.merchant_category
    HAVING COUNT(*) >= 50
)
SELECT TOP 25
    merchant_id,
    merchant_name,
    merchant_category,
    txns,
    CAST(fraud_rate AS DECIMAL(5,2))                            AS fraud_rate_pct,
    chargebacks,
    CAST(fraud_value AS DECIMAL(12,2))                          AS fraud_value,
    CAST(
        0.6 * PERCENT_RANK() OVER (ORDER BY fraud_rate)
      + 0.4 * PERCENT_RANK() OVER (ORDER BY fraud_value)
    AS DECIMAL(4,3))                                            AS risk_score,
    NTILE(4) OVER (ORDER BY fraud_rate)                         AS risk_quartile
FROM merch
ORDER BY risk_score DESC;

-- GEOGRAPHIC: country and region fraud rates
-- Business question: which countries carry the most fraud?
-- Technique: multi-table JOIN, geographic aggregation, DENSE_RANK within region.

SELECT
    g.region,
    g.country_name,
    COUNT(*)                                                         AS txns,
    SUM(CAST(f.is_fraud AS INT))                                     AS fraud_txns,
    CAST(100.0 * SUM(CAST(f.is_fraud AS INT)) / COUNT(*)
         AS DECIMAL(5,2))                                            AS fraud_rate_pct,
    SUM(CASE WHEN f.is_fraud = 1 THEN f.amount ELSE 0 END)           AS fraud_value,
    DENSE_RANK() OVER (
        PARTITION BY g.region
        ORDER BY 1.0 * SUM(CAST(f.is_fraud AS INT)) / COUNT(*) DESC
    )                                                                AS rank_in_region
FROM fact_transactions f
JOIN dim_geography g ON f.transaction_country = g.country_name
GROUP BY g.region, g.country_name
ORDER BY fraud_rate_pct DESC;

-- GEOGRAPHIC: cross-border corridors
-- Business question: which country-to-country routes carry elevated fraud?
-- A customer transacting outside their home country is the signal.
-- Technique: multi-table JOIN, HAVING to remove low-volume noise.

SELECT
    c.home_country,
    f.transaction_country,
    COUNT(*)                                                         AS txns,
    SUM(CAST(f.is_fraud AS INT))                                     AS fraud_txns,
    CAST(100.0 * SUM(CAST(f.is_fraud AS INT)) / COUNT(*)
         AS DECIMAL(5,2))                                            AS fraud_rate_pct
FROM fact_transactions f
JOIN dim_customers c ON f.customer_id = c.customer_id
WHERE c.home_country <> f.transaction_country
GROUP BY c.home_country, f.transaction_country
HAVING COUNT(*) >= 30
ORDER BY fraud_rate_pct DESC;

-- CUSTOMER PROFILES: tenure effect
-- Business question: do new accounts carry more fraud risk than established ones?
-- Technique: multi-table JOIN, DATEDIFF tenure calculation, CASE banding.

SELECT
    CASE
        WHEN DATEDIFF(DAY, c.signup_date, f.transaction_timestamp) < 30
             THEN '1. Under 30 days'
        WHEN DATEDIFF(DAY, c.signup_date, f.transaction_timestamp) < 90
             THEN '2. 30 to 90 days'
        WHEN DATEDIFF(DAY, c.signup_date, f.transaction_timestamp) < 365
             THEN '3. 90 to 365 days'
        ELSE '4. Over a year'
    END                                                              AS tenure_band,
    COUNT(*)                                                         AS txns,
    SUM(CAST(f.is_fraud AS INT))                                     AS fraud_txns,
    CAST(100.0 * SUM(CAST(f.is_fraud AS INT)) / COUNT(*)
         AS DECIMAL(5,2))                                            AS fraud_rate_pct
FROM fact_transactions f
JOIN dim_customers c ON f.customer_id = c.customer_id
WHERE f.transaction_timestamp >= c.signup_date
GROUP BY CASE
        WHEN DATEDIFF(DAY, c.signup_date, f.transaction_timestamp) < 30
             THEN '1. Under 30 days'
        WHEN DATEDIFF(DAY, c.signup_date, f.transaction_timestamp) < 90
             THEN '2. 30 to 90 days'
        WHEN DATEDIFF(DAY, c.signup_date, f.transaction_timestamp) < 365
             THEN '3. 90 to 365 days'
        ELSE '4. Over a year' END
ORDER BY tenure_band;

-- CUSTOMER PROFILES: highest value fraud customers
-- Business question: which customers drive the most fraud losses?
-- Technique: CTE, multi-table JOIN, RANK window function.

WITH cust AS (
    SELECT
        c.customer_id,
        c.customer_segment,
        c.kyc_status,
        c.home_country,
        COUNT(*)                                                AS txns,
        SUM(CAST(f.is_fraud AS INT))                            AS fraud_txns,
        SUM(CASE WHEN f.is_fraud = 1 THEN f.amount ELSE 0 END)  AS fraud_value
    FROM fact_transactions f
    JOIN dim_customers c ON f.customer_id = c.customer_id
    GROUP BY c.customer_id, c.customer_segment, c.kyc_status, c.home_country
    HAVING SUM(CAST(f.is_fraud AS INT)) > 0
)
SELECT TOP 50
    customer_id,
    customer_segment,
    kyc_status,
    home_country,
    txns,
    fraud_txns,
    CAST(fraud_value AS DECIMAL(12,2))                          AS fraud_value,
    CAST(100.0 * fraud_txns / txns AS DECIMAL(5,2))             AS personal_fraud_rate_pct,
    RANK() OVER (ORDER BY fraud_value DESC)                     AS value_rank
FROM cust
ORDER BY fraud_value DESC;

-- CUSTOMER PROFILES: velocity bursts
-- Business question: are there customers making rapid sequences of fraud transactions?
-- These are the fraud ring members. They hit fast and in clusters.
-- Technique: window function LAG to find time between consecutive fraud transactions.

WITH fraud_seq AS (
    SELECT
        customer_id,
        transaction_timestamp,
        amount,
        -- LAG looks back one row within the same customer's fraud history
        -- and returns the previous fraud transaction timestamp
        LAG(transaction_timestamp) OVER (
            PARTITION BY customer_id
            ORDER BY transaction_timestamp
        )                                                        AS prev_ts,
        COUNT(*) OVER (PARTITION BY customer_id)                 AS lifetime_fraud_txns
    FROM fact_transactions
    WHERE is_fraud = 1
)
SELECT
    customer_id,
    lifetime_fraud_txns,
    SUM(CASE WHEN DATEDIFF(HOUR, prev_ts, transaction_timestamp) <= 24
             THEN 1 ELSE 0 END)                                  AS rapid_followups
FROM fraud_seq
GROUP BY customer_id, lifetime_fraud_txns
HAVING SUM(CASE WHEN DATEDIFF(HOUR, prev_ts, transaction_timestamp) <= 24
               THEN 1 ELSE 0 END) >= 3
ORDER BY rapid_followups DESC;

-- STEP 4: OPTIMIZATION: baseline measurement
-- Before I change anything, I measure the cost. Logical reads is the number that matters.
-- It tells me how many data pages SQL Server read to answer the query.
-- Lower logical reads means less work, faster query, better at scale.
-- Turn on Ctrl+M (actual execution plan) alongside this for the full picture.

SET STATISTICS IO, TIME ON;

-- This is the slow version. No indexes. Full table scan on every run.
-- At 250,000 rows this is already measurable. At 10 million rows it becomes a problem.
SELECT
    m.merchant_category,
    COUNT(*)                        AS txns,
    AVG(CAST(f.is_fraud AS FLOAT))  AS fraud_rate
FROM fact_transactions f
JOIN dim_merchants m ON f.merchant_id = m.merchant_id
WHERE f.transaction_timestamp >= '2026-01-01'
GROUP BY m.merchant_category;

SET STATISTICS IO, TIME OFF;

-- OPTIMIZATION: index the fact table
-- Right now fact_transactions is a heap. No order. Every query scans it top to bottom.
-- I give it structure so SQL Server can seek instead of scan.

-- Step 1. Add a surrogate key so the table has a clustered index.
-- A clustered index gives the table physical order on disk.
ALTER TABLE fact_transactions ADD txn_sk BIGINT IDENTITY(1,1);
CREATE CLUSTERED INDEX cix_fact ON fact_transactions(txn_sk);

-- Step 2. Foreign key lookup indexes.
-- Every JOIN on customer_id and merchant_id benefits from these.
CREATE NONCLUSTERED INDEX ix_fact_customer
    ON fact_transactions(customer_id);

CREATE NONCLUSTERED INDEX ix_fact_merchant
    ON fact_transactions(merchant_id);

-- Step 3. Covering index on transaction_timestamp.
-- INCLUDE carries is_fraud, amount, merchant_id alongside the index.
-- The query gets everything it needs from the index without touching the main table.
-- This is called a covering index and it is the most powerful single optimization here.
CREATE NONCLUSTERED INDEX ix_fact_date
    ON fact_transactions(transaction_timestamp)
    INCLUDE (is_fraud, amount, merchant_id);

-- Step 4. Geographic grouping index.
CREATE NONCLUSTERED INDEX ix_fact_country
    ON fact_transactions(transaction_country)
    INCLUDE (is_fraud, amount);
GO

-- OPTIMIZATION: after indexing. Same query, same data.
-- I expect logical reads to drop significantly from 4,368.
-- The covering index ix_fact_date carries is_fraud, amount and merchant_id.
-- SQL Server seeks the index instead of scanning the whole table.

SET STATISTICS IO, TIME ON;

SELECT
    m.merchant_category,
    COUNT(*)                        AS txns,
    AVG(CAST(f.is_fraud AS FLOAT))  AS fraud_rate
FROM fact_transactions f
JOIN dim_merchants m ON f.merchant_id = m.merchant_id
WHERE f.transaction_timestamp >= '2026-01-01'
GROUP BY m.merchant_category;

SET STATISTICS IO, TIME OFF;

-- OPTIMIZATION: correlated subquery vs window function
-- A correlated subquery runs once per outer row.
-- On 247,040 rows that is 247,040 sub-executions. Painful.
-- A window function does the same job in one pass.

-- SLOW pattern. Do not run on the full table. Shown here for comparison only.
-- SELECT f.transaction_id, f.amount,
--        (SELECT AVG(f2.amount)
--         FROM fact_transactions f2
--         WHERE f2.merchant_id = f.merchant_id) AS merchant_avg_amount
-- FROM fact_transactions f
-- WHERE f.is_fraud = 1;

-- FAST: window function. One pass. Same result. This is what I actually run.
-- AVG(amount) OVER (PARTITION BY merchant_id) groups by merchant without collapsing rows.
SELECT
    transaction_id,
    amount,
    AVG(amount) OVER (PARTITION BY merchant_id) AS merchant_avg_amount
FROM fact_transactions
WHERE is_fraud = 1;
