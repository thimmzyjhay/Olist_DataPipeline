{{
    config(
        materialized="incremental",
        unique_key="review_id",
        incremental_strategy="merge",
    )
}}

select *
from
    {{ ref("stg_order_review") }} {{ incremental_filter(column="ingestion_timestamp") }}
qualify
    row_number() over (
        partition by review_id order by ingestion_timestamp desc, source_file_name desc
    )
    = 1
