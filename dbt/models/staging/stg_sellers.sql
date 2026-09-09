{{ config(materialized="table") }}

with
    source as (select * from {{ source("ecommerce", "sellers") }}),

    renamed as (

        select
            cast(trim(seller_id) as string) seller_id,
            cast(trim(seller_zip_code_prefix) as int) seller_zip_code_prefix,
            cast(trim(seller_city) as string) seller_city,
            cast(trim(seller_state) as string) seller_state
        from source

    )

select *
from renamed
