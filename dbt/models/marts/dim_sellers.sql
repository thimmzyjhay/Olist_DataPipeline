{{ config(materialized="view") }}

select seller_id, seller_zip_code_prefix, seller_city, seller_state
from {{ ref("sellers_dedup") }}
