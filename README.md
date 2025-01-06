# **Campaign Performance Analysis with dbt**

## **Project Overview**
This project analyzes advertising campaign performance data using dbt (Data Build Tool). The analysis focuses on metrics such as spend, conversions, and Return on Ad Spend (ROAS) to provide actionable insights and recommendations. Codes used on the analisis are listed at the bottom.

Key findings include:
- Identification of high-performing campaigns and channels.
- Analysis of underperforming campaigns to optimize future strategies.

Summary And recommendations: [Campaign Performance Summary](https://raw.githubusercontent.com/DiegoQuirch/improvado/main/Campaign%20Performance%20Summary.docx)


---

## **Getting Started**

### **Prerequisites**
Before running this project, ensure the following tools are installed:
1. dbt Core
2. Google BigQuery (where the raw tables where created).

Important: a service account was used for the BQ project.

### **Setup Instructions**
1. **Clone the Repository:**
   ```bash
   
   git clone https://github.com/your-username/campaign-performance-analysis.git
   cd campaign-performance-analysis

2. Open the profiles.yml file in your .dbt directory and configure the BigQuery connection:
  ```yaml
campaign_analysis:
  outputs:
    dev:
      type: bigquery
      method: oauth
      project: improvado-hw-446913
      dataset: improvado-hw-446913.improvado
      threads: 4
      timeout_seconds: 300
      priority: interactive
      location: US
  target: dev
```

3. Install dbt Dependencies:
   ```bash
   
   dbt deps

## **Running the Project**

### **1. Test the Connection**
Verify that the connection to BigQuery is working:
```bash
dbt debug
```
2. Run Tests
Run all defined tests to ensure data integrity:

```bash
dbt test

```
3. Execute Models
Build the dbt models to create the final datasets:

```bash
dbt run
```
4. Generate and View Documentation
Generate a browsable HTML documentation site:

```bash
dbt docs generate
dbt docs serve
```

### **Project Structure**
```plaintext
campaign-performance-analysis/
├── models/
│   ├── staging/                # Staging models for raw data
│   ├── dimensions/             # Dimension tables (e.g., campaigns)
│   ├── facts/                  # Fact tables (e.g., performance metrics)
├── tests/                      # Data integrity tests
├── macros/                     # Custom macros for dbt
├── dbt_project.yml             # dbt project configuration
└── README.md                   # Project documentation

```
### **Data Sources**
The project uses the following data sources:

*raw_conversions*: Contains campaign conversion data.

*raw_ad_spend*: Contains spend data for campaigns.

*raw_campaigns*: Contains metadata about campaigns (e.g., names, channels).

## **Looker screenshot**

![BI Screen](https://raw.githubusercontent.com/DiegoQuirch/improvado/main/BI_screen.jpg)

## **Results**
Total spend and conversion per campaign (results in [total_spend_and_conversions.csv](https://raw.githubusercontent.com/DiegoQuirch/improvado/main/total_spend_and_conversions.csv))

Code used:
```sql
WITH
  camp AS(
  SELECT
    campaign_id,
    campaign_name
  FROM
    improvado-hw-446913.improvado.dim_campaigns ),
  perf AS (
  SELECT
    campaign_id,
    spend,
    conversions
  FROM
    improvado-hw-446913.improvado.fct_campaign_performance )
SELECT
  camp.campaign_name,
  SUM(perf.spend) AS total_spend,
  SUM(perf.conversions) AS total_conversions
FROM
  camp
LEFT JOIN
  perf
ON
  camp.campaign_id = perf.campaign_id
```
Channel with highest ROAS (result in [highest_roas.csv](https://raw.githubusercontent.com/DiegoQuirch/improvado/main/highest_roas.csv))

Code used:
```sql
WITH
  camp AS (
  SELECT
    campaign_id,
    channel
  FROM
    improvado-hw-446913.improvado.dim_campaigns ),
  perf AS (
  SELECT
    campaign_id,
    ROAS
  FROM
    improvado-hw-446913.improvado.fct_campaign_performance )
SELECT
  camp.channel,
  MAX(perf.ROAS) AS highest_ROAS
FROM
  camp
LEFT JOIN
  perf
ON
  camp.campaign_id = perf.campaign_id
GROUP BY
  camp.channel
ORDER BY
  highest_ROAS DESC
LIMIT
  1
```

Trend analysis (results in [trend.csv](https://raw.githubusercontent.com/DiegoQuirch/improvado/main/trend.csv))

Code used:
```sql
-- Analyze campaign performance trends by splitting the period 2023-09-01 to 2023-09-30 into two halves

-- Define the performance data source
WITH campaign_performance AS (
  SELECT
    campaign_id,
    spend,
    conversions,
    date
  FROM improvado-hw-446913.improvado.fct_campaign_performance
),

-- Aggregate data for the first half of the period: 2023-09-01 to 2023-09-15
first_half AS (
  SELECT
    campaign_id,
    SUM(spend) AS total_spend_first_half,
    SUM(conversions) AS total_conversions_first_half
  FROM campaign_performance
  WHERE date BETWEEN '2023-09-01' AND '2023-09-15'
  GROUP BY campaign_id
),

-- Aggregate data for the second half of the period: 2023-09-16 to 2023-09-30
second_half AS (
  SELECT
    campaign_id,
    SUM(spend) AS total_spend_second_half,
    SUM(conversions) AS total_conversions_second_half
  FROM campaign_performance
  WHERE date BETWEEN '2023-09-16' AND '2023-09-30'
  GROUP BY campaign_id
)

-- Compare the performance metrics between the two halves
SELECT
  s.campaign_id,
  f.total_spend_first_half,
  s.total_spend_second_half,
  f.total_conversions_first_half,
  s.total_conversions_second_half,
  CASE 
    -- Check if both spend and conversions decreased in the second half
    WHEN s.total_spend_second_half < f.total_spend_first_half
      AND s.total_conversions_second_half < f.total_conversions_first_half THEN 'Decreasing'
    ELSE 'Not Decreasing'
  END AS performance_trend
FROM second_half s
LEFT JOIN first_half f
  ON s.campaign_id = f.campaign_id
WHERE s.total_spend_second_half < f.total_spend_first_half
   OR s.total_conversions_second_half < f.total_conversions_first_half
ORDER BY performance_trend DESC;



