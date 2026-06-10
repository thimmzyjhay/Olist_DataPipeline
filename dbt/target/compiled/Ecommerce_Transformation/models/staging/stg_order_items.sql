

WITH source AS (SELECT *
             FROM E_COMMERCE.BRONZE_RAW.order_items
            ),

renamed AS (

    SELECT
        CAST(TRIM(order_id) AS STRING) order_id,
        CAST(TRIM(order_item_id) AS STRING) order_item_id,
        CAST(TRIM(product_id) AS STRING) product_id,
        CAST(TRIM(seller_id) AS STRING) seller_id,
        CAST(TRIM(shipping_limit_date) AS TIMESTAMP) shipping_limit_date,
        CAST(TRIM(price) AS FLOAT) price,
        CAST(TRIM(freight_value) AS FLOAT) freight_value
    FROM source

)

SELECT * FROM renamed