{{ config(materialized="table") }}

with
    source as (select * from {{ source("ecommerce", "orders") }}),

    renamed as (

        select
            cast(trim(order_id) as string) order_id,
            cast(trim(customer_id) as string) customer_id,
            cast(trim(order_status) as string) order_status,
            cast(trim(order_purchase_timestamp) as timestamp) order_purchase_timestamp,
            cast(trim(order_approved_at) as timestamp) order_approved_at,
            cast(
                trim(order_delivered_carrier_date) as timestamp
            ) order_delivered_carrier_date,
            cast(
                trim(order_delivered_customer_date) as timestamp
            ) order_delivered_customer_date,
            cast(
                trim(order_estimated_delivery_date) as timestamp
            ) order_estimated_delivery_date
        from source

    )

select *
from renamed
