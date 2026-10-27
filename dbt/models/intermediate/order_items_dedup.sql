{{
    config(
        materialized="incremental",
        unique_key="order_item_id",
        incremental_strategy="merge",
    )
}}

select *
from {{ ref("stg_order_items") }} {{ incremental_filter(column="ingestion_timestamp") }}
qualify
    row_number() over (
        partition by order_item_id
        order by ingestion_timestamp desc, source_file_name desc
    )
    = 1
