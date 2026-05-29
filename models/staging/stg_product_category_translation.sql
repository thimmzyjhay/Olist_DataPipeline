{{
    config(materialized='view')
}}

with source as (
    SELECT *
    FROM {{source('ecommerce', 'product_category_name_translation')}}
)

renamed as (

    select
        product_category_name,
        product_category_name_english
    from source

)

select * from renamed