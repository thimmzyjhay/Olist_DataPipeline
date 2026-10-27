-- fct_order_items.sql
{{ config(materialized="table") }}

select
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
from {{ ref("order_items_dedup") }}
