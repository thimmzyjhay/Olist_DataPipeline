{{ config(materialized='view') }}

WITH source AS (
    SELECT *
    FROM {{ ref('stg_orders') }}
),

order_metrics AS (
    SELECT
        order_id,
        customer_id,
        order_status,
        DATEDIFF(day, order_purchase_timestamp, order_delivered_customer_date) AS delivery_days,
        DATEDIFF(day, order_purchase_timestamp, order_approved_at) AS approval_lag_days,
        DATEDIFF(day, order_delivered_customer_date, order_estimated_delivery_date) AS delivery_diff_days,
        CASE 
            WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 
            ELSE 0 
        END AS late_delivery_flag
    FROM source
),

order_dis AS (
    SELECT 
        COUNT(DISTINCT order_id) AS total_orders,
        AVG(delivery_days) AS avg_delivery_time,
        SUM(delivery_days) AS total_delivery_time,
        AVG(approval_lag_days) AS avg_approval_lag,
        SUM(late_delivery_flag) AS late_orders
    FROM order_metrics
)

SELECT *
FROM order_dis
