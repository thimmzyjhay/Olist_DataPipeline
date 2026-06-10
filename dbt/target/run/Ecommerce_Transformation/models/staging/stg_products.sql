
  
    

create or replace transient table E_COMMERCE.silver.stg_products
    
    
    
    as (

with source AS (
    SELECT *
    FROM E_COMMERCE.BRONZE_RAW.products
),

renamed AS (

    SELECT
        CAST(TRIM(product_id) AS STRING) product_id,
        CAST(TRIM(product_category_name) AS STRING) product_category_name,
        CAST(TRIM(product_name_lenght) AS INT) product_name_lenght,
        CAST(TRIM(product_description_lenght) AS INT) product_description_lenght,
        CAST(TRIM(product_photos_qty) AS INT) product_photos_qty,
        CAST(TRIM(product_weight_g) AS FLOAT) product_weight_g,
        CAST(TRIM(product_length_cm) AS FLOAT) product_length_cm,
        CAST(TRIM(product_height_cm) AS FLOAT) product_height_cm,
        CAST(TRIM(product_width_cm) AS FLOAT) product_width_cm
    FROM source

)

SELECT * FROM renamed
    )
;


  