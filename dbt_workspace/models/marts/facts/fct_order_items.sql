{{
    config(materialized='view')
}}

WITH source AS (SELECT *
             FROM {{ ref('stg_order_items') }}
            )

SELECT 
    order_id,
    COUNT(order_item_id) AS total_items,
    SUM(price) AS total_item_value,
    SUM(freight_value) AS total_freight_value,
    AVG(price) AS avg_item_price,
    COUNT(DISTINCT product_id) AS distinct_products,
    COUNT(DISTINCT seller_id) AS distinct_sellers,
    MAX(shipping_limit_date) AS latest_shipping_limit
FROM source
GROUP BY order_id