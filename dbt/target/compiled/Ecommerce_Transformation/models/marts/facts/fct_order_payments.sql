

WITH source AS (
    SELECT *
    FROM E_COMMERCE.silver.stg_order_payments
),

payment_summary AS (
    SELECT 
        order_id,
        SUM(payment_value) AS total_payment_value,
        COUNT(payment_sequential) AS payment_attempts,
        MAX(payment_installments) AS max_installments,
        COUNT(DISTINCT payment_type) AS distinct_payment_types
    FROM source
    GROUP BY order_id
),

first_payment AS (
    SELECT
        order_id,
        FIRST_VALUE(payment_type) OVER (
            PARTITION BY order_id 
            ORDER BY payment_sequential
        ) AS first_payment_method
    FROM source
)

SELECT 
    ps.order_id,
    ps.total_payment_value,
    ps.payment_attempts,
    ps.max_installments,
    ps.distinct_payment_types,
    fp.first_payment_method
FROM payment_summary ps
JOIN first_payment fp 
    ON ps.order_id = fp.order_id