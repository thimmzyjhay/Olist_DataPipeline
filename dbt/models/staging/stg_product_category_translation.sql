{{
    config(materialized='table')
}}

WITH source AS (
    SELECT *
    FROM {{source('ecommerce', 'product_category_translation')}}
),

renamed AS (

    SELECT
        CAST(TRIM(product_category_name) AS STRING) product_category_name,
        CAST(TRIM(product_category_name_english) AS STRING) product_category_name_english
    FROM source

)

SELECT * FROM renamed