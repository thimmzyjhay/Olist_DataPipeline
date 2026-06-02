{{
    config(materialized='table')
}}

WITH source AS (
    SELECT *
    FROM {{source('ecommerce', 'order_reviews')}}
)

renamed AS (

    SELECT
        CAST(TRIM(review_id) AS STRING) review_id,
        CAST(TRIM(order_id) AS INT) order_id,
        CAST(TRIM(review_score) AS INT) review_score,
        CAST(TRIM(review_comment_title) AS STRING) review_comment_title,
        CAST(TRIM(review_comment_message) AS STRING) review_comment_message,
        CAST(TRIM(review_creation_date) AS TIMESTAMP) review_creation_date,
        CAST(TRIM(review_answer_timestamp) AS TIMESTAMP) review_answer_timestamp
    FROM source

)

SELECT * FROM renamed