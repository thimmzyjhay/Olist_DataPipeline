
  
    

create or replace transient table E_COMMERCE.silver.stg_customers
    
    
    
    as (

WITH source AS (

    SELECT * FROM E_COMMERCE.BRONZE_RAW.customers

),

renamed AS (

    SELECT
        CAST(TRIM(customer_id) AS STRING) customer_id,
        CAST(TRIM(customer_unique_id) AS STRING) customer_unique_id,
        CAST(TRIM(customer_zip_code_prefix) AS STRING) customer_zip_code_prefix,
        CAST(TRIM(customer_city) AS STRING) customer_city,
        CAST(TRIM(customer_state) AS STRING) customer_state
    FROM source

)

SELECT * FROM renamed
    )
;


  