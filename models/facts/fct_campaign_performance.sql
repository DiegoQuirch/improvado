{{ config(
    materialized='table'
) }}
 -- Join data
WITH joined_data AS (
    SELECT
        spend.campaign_id,
        spend.date,
        spend.spend,
        -- If there are no conversions for a campaign on a given day, set the value to 0
        COALESCE(CAST(conv.conversions.conversions AS INT64), 0) AS conversions
    FROM {{ ref('stg_ad_spend') }} AS spend
    -- Join the ad spend data with the conversions data
    LEFT JOIN {{ ref('stg_conversions') }} AS conv
    ON spend.date = conv.date
       AND spend.campaign_id = conv.campaign_id
),

-- Calculate metrics
joined_metrics AS (
    SELECT
        campaign_id,
        date,
        spend,
        conversions,
        -- Calculate conversion rate
        CASE 
            WHEN spend > 0 THEN ROUND(conversions / spend, 5)
            ELSE 0 
        END AS conversion_rate,
        -- Calculate ROAS
        CASE 
            WHEN spend > 0 THEN ROUND((conversions * 100) / spend, 2) 
            ELSE 0
        END AS ROAS
    FROM joined_data
)
 -- Final select
SELECT 
    campaign_id,
    date,
    spend,
    conversions,
    conversion_rate,
    ROAS
FROM joined_metrics

