{{
    config(
        materialized="incremental",
        unique_key="order_id",
        incremental_strategy="merge",
    )
}}

select *
from {{ ref("stg_orders") }} {{ incremental_filter(column="ingestion_timestamp") }}
qualify
    row_number() over (
        partition by order_id order by ingestion_timestamp desc, source_file_name desc
    )
    = 1
