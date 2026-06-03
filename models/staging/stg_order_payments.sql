{{
    config(materialized='table')
}}

WITH source AS (
    SELECT *
    FROM {{source('ecommerce', 'order_payments')}}
),

renamed AS (

    SELECT
        CAST(TRIM(order_id) AS STRING) order_id,
        CAST(TRIM(payment_sequential) AS INT) payment_sequential,
        CAST(TRIM(payment_type) AS STRING) payment_type,
        CAST(TRIM(payment_installments) AS INT) payment_installments,
        CAST(TRIM(payment_value) AS FLOAT) payment_value
    FROM source

)
SELECT * FROM renamed