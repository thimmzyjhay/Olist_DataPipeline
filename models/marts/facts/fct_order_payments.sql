{{
    config(materialized='view')
}}

WITH source AS (SELECT *
             FROM {{source ('ecommerce', 'order_items')}}
            )

WITH payment_summary AS (
    SELECT 
        order_id,
        SUM(payment_value) AS total_payment_value,
        COUNT(payment_sequential) AS payment_attempts,
        MAX(payment_installments) AS max_installments,
        COUNT(DISTINCT payment_type) AS distinct_payment_types
    FROM source
    GROUP BY order_id
)
SELECT 
    ps.*,
    FIRST_VALUE(payment_type) OVER (PARTITION BY order_id ORDER BY payment_sequential) AS first_payment_method
FROM source
JOIN payment_summary ps ON source.order_id = ps.order_id;
