{{
    config(materialized='table')
}}

WITH source AS (
    SELECT *
    FROM {{source('ecommerce', 'sellers')}}
),

renamed AS (

    SELECT
        CAST(TRIM(seller_id) AS STRING) seller_id,
        CAST(TRIM(seller_zip_code_prefix) AS INT) seller_zip_code_prefix,
        CAST(TRIM(seller_city) AS STRING) seller_city,
        CAST(TRIM(seller_state) AS STRING) seller_state
    FROM source

)

SELECT * FROM renamed