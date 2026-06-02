{{
    config(materialized='view')
}}

WITH source AS (SELECT *
             FROM {{source ('ecommerce', 'order_items')}}
            ),

item_summary AS (
    SELECT 
        order_id,
        COUNT(order_item_id) AS total_items,
        SUM(price) AS total_item_value,
        SUM(freight_value) AS total_freight_value
    FROM fact_order_items
    GROUP BY order_id
),
payment_summary AS (
    SELECT 
        order_id,
        SUM(payment_value) AS total_payment_value,
        COUNT(payment_sequential) AS payment_attempts,
        MAX(payment_installments) AS max_installments,
        FIRST_VALUE(payment_type) OVER (
            PARTITION BY order_id 
            ORDER BY payment_sequential
        ) AS first_payment_method
    FROM fact_order_payment
),
review_summary AS (
    SELECT 
        order_id,
        AVG(review_score) AS avg_review_score,
        COUNT(review_id) AS review_count,
        FIRST_VALUE(review_comment_message) OVER (
            PARTITION BY order_id 
            ORDER BY review_creation_date DESC
        ) AS latest_review_comment
    FROM fact_order_reviews
)
SELECT 
    i.order_id,
    i.total_items,
    i.total_item_value,
    i.total_freight_value,
    p.total_payment_value,
    p.payment_attempts,
    p.max_installments,
    p.first_payment_method,
    r.avg_review_score,
    r.review_count,
    r.latest_review_comment
FROM item_summary i
LEFT JOIN payment_summary p ON i.order_id = p.order_id
LEFT JOIN review_summary r ON i.order_id = r.order_id;
