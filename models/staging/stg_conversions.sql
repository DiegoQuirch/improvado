-- This model is used to clean and prepare the data from the raw_conversions table for further processing
WITH conversions AS (
    SELECT
        -- Cast the data to the correct data types
        CAST(campaign_id AS INT64) AS campaign_id,  
        CAST(conversions AS INT64) AS conversions,  
        CAST(date AS DATE) AS date  
    FROM {{ source('raw', 'raw_conversions') }}
    -- Filter out negative conversion values
    WHERE SAFE_CAST(conversions AS INT64) >= 0 
)

SELECT
    campaign_id,
    date,
    conversions
FROM conversions