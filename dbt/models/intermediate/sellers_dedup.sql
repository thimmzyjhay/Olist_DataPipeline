{{ config(materialized="table") }}

select *
from {{ ref("stg_sellers") }}
qualify
    row_number() over (
        partition by seller_id order by ingestion_timestamp desc, source_file_name desc
    )
    = 1
