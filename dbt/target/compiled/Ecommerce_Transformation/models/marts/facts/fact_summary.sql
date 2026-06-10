

WITH item_summary AS (
    SELECT 
        order_id,
        COUNT(order_item_id) AS total_items,
        SUM(price) AS total_item_value,
        SUM(freight_value) AS total_freight_value
    FROM E_COMMERCE.silver.stg_order_items
    GROUP BY order_id
),

payment_agg AS (
    SELECT 
        order_id,
        SUM(payment_value) AS total_payment_value,
        COUNT(payment_sequential) AS payment_attempts,
        MAX(payment_installments) AS max_installments
    FROM E_COMMERCE.silver.stg_order_payments
    GROUP BY order_id
),

payment_first AS (
    SELECT
        order_id,
        FIRST_VALUE(payment_type) OVER (
            PARTITION BY order_id 
            ORDER BY payment_sequential
        ) AS first_payment_method
    FROM E_COMMERCE.silver.stg_order_payments
),

review_agg AS (
    SELECT 
        order_id,
        AVG(review_score) AS avg_review_score,
        COUNT(review_id) AS review_count
    FROM E_COMMERCE.silver.stg_order_reviews
    GROUP BY order_id
),

review_latest AS (
    SELECT
        order_id,
        FIRST_VALUE(review_comment_message) OVER (
            PARTITION BY order_id 
            ORDER BY review_creation_date DESC
        ) AS latest_review_comment
    FROM E_COMMERCE.silver.stg_order_reviews
)

SELECT 
    i.order_id,
    i.total_items,
    i.total_item_value,
    i.total_freight_value,
    p.total_payment_value,
    p.payment_attempts,
    p.max_installments,
    pf.first_payment_method,
    r.avg_review_score,
    r.review_count,
    rl.latest_review_comment
FROM item_summary i
LEFT JOIN payment_agg p ON i.order_id = p.order_id
LEFT JOIN payment_first pf ON i.order_id = pf.order_id
LEFT JOIN review_agg r ON i.order_id = r.order_id
LEFT JOIN review_latest rl ON i.order_id = rl.order_id