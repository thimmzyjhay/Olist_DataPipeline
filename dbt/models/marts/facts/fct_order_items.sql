{{ config(materialized="view") }}

select
    order_id,
    count(*) as total_items,
    sum(price) as total_item_value,
    sum(freight_value) as total_freight_value,
    avg(price) as avg_item_price,
    count(distinct product_id) as distinct_products,
    count(distinct seller_id) as distinct_sellers,
    max(shipping_limit_date) as latest_shipping_limit
from {{ ref("stg_order_items") }}
group by order_id
