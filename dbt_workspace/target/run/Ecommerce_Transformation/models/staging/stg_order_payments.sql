
  
    

create or replace transient table E_COMMERCE.silver.stg_order_payments
    
    
    
    as (

WITH source AS (
    SELECT *
    FROM E_COMMERCE.BRONZE_RAW.order_payments
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
    )
;


  