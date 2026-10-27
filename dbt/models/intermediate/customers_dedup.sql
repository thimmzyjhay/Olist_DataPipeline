{{ config(materialized="table") }}

select *
from {{ ref("stg_customers") }}
qualify
    row_number() over (
        partition by customer_id
        order by ingestion_timestamp desc, source_file_name desc
    )
    = 1
