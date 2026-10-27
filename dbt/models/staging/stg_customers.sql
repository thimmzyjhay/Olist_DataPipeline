{{ config(materialized="table") }}

with
    source as (select * from {{ source("ecommerce", "customers") }}),

    renamed as (

        select
            cast(trim(customer_id) as string) customer_id,
            cast(trim(customer_unique_id) as string) customer_unique_id,
            cast(trim(customer_zip_code_prefix) as string) customer_zip_code_prefix,
            cast(trim(customer_city) as string) customer_city,
            cast(trim(customer_state) as string) customer_state
            current_timestamp() as loaded_at
        from source

    )

select *
from renamed
