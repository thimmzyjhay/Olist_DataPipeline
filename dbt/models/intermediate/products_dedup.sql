{{ config(materialized="table") }}

select *
from {{ ref("stg_products") }}
qualify
    row_number() over (
        partition by product_id order by ingestion_timestamp desc, source_file_name desc
    )
    = 1
