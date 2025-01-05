{{ config(
    materialized='table'
) }}

WITH cleaned_campaigns AS (
    SELECT 
        campaign_id,
        campaign_name,
        channel
    FROM {{ ref('stg_campaigns') }}
)
SELECT 
    campaign_id,
    campaign_name,
    channel,
    CURRENT_TIMESTAMP() AS load_datetime
FROM cleaned_campaigns
