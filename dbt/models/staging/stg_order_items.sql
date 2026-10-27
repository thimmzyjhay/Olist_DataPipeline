{{ config(materialized="table") }}

with
    source as (select * from {{ source("ecommerce", "order_items") }}),

    renamed as (

        select
            cast(trim(order_id) as string) order_id,
            cast(trim(order_item_id) as string) order_item_id,
            cast(trim(product_id) as string) product_id,
            cast(trim(seller_id) as string) seller_id,
            cast(trim(shipping_limit_date) as timestamp) shipping_limit_date,
            cast(trim(price) as number(12, 2)) price,
            cast(trim(freight_value) as number(12, 2)) freight_value
            current_timestamp() as loaded_at
        from source

    )

select *
from renamed
