-- This model is used to clean and prepare the raw_campaigns table for further processing
with campaigns as (
    select
        -- Cast the data to the correct data types
        campaign_id,
        lower(trim(campaign_name)) as campaign_name,  
        lower(trim(channel)) as channel              
    from {{ source('raw', 'raw_campaigns') }})

select
    campaign_id,
    campaign_name,
    channel
from campaigns
