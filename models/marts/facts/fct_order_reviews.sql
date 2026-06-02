{{
    config(materialized='view')
}}

WITH source AS (SELECT *
             FROM {{source ('ecommerce', 'order_items')}}
            )
WITH review_summary AS (
    SELECT 
        order_id,
        AVG(review_score) AS avg_review_score,
        COUNT(review_id) AS review_count,
        MAX(review_creation_date) AS latest_review_date
    FROM source
    GROUP BY order_id
)
SELECT 
    rs.*,
    FIRST_VALUE(review_comment_message) OVER (
        PARTITION BY order_id
        ORDER BY review_creation_date DESC
    ) AS latest_review_comment
FROM source
JOIN review_summary rs ON source.order_id = rs.order_id;
