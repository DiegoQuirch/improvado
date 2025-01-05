-- This model is used to load ad spend data from raw_ad_spend table to ad_spend table
with ad_spend as (
    select
        -- Cast the data to the correct data types
         CAST(campaign_id AS INT64) AS campaign_id,
        CAST(spend AS NUMERIC) AS spend,
        CAST(date AS DATE) AS date  
    from {{ source('raw', 'raw_ad_spend') }}
    -- Filter out negative spend values
    where spend >= 0)

select
    campaign_id,
    date,
    spend
from ad_spend
