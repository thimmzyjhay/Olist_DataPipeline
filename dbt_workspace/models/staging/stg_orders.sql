{{ config(materialized='table') }}

WITH source as (

    SELECT * FROM {{ source('ecommerce', 'orders') }}

),

renamed AS (

    SELECT
        CAST(TRIM(order_id) AS STRING) order_id,
        CAST(TRIM(customer_id) AS STRING) customer_id,
        CAST(TRIM(order_status) AS STRING) order_status,
        CAST(TRIM(order_purchase_timestamp) AS TIMESTAMP) order_purchase_timestamp,
        CAST(TRIM(order_approved_at) AS TIMESTAMP) order_approved_at,
        CAST(TRIM(order_delivered_carrier_date) AS TIMESTAMP) order_delivered_carrier_date,
        CAST(TRIM(order_delivered_customer_date) AS TIMESTAMP) order_delivered_customer_date,
        CAST(TRIM(order_estimated_delivery_date) AS TIMESTAMP) order_estimated_delivery_date
    FROM source

)

SELECT * FROM renamed