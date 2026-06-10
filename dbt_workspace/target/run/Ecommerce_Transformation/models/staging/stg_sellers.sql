
  
    

create or replace transient table E_COMMERCE.silver.stg_sellers
    
    
    
    as (

WITH source AS (
    SELECT *
    FROM E_COMMERCE.BRONZE_RAW.sellers
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
    )
;


  