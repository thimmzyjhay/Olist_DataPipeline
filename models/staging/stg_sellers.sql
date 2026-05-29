{{
    config(materialized='view')
}}

with source as (
    SELECT *
    FROM {{source('ecommerce', 'sellers')}}
)

renamed as (

    select
        seller_id,
        seller_zip_code_prefix,
        seller_city,
        seller_state
    from source

)

select * from renamed