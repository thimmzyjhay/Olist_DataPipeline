{{ config(materialized="table") }}

with
    source as (select * from {{ source("ecommerce", "order_payments") }}),

    renamed as (

        select
            cast(trim(order_id) as string) order_id,
            cast(trim(payment_sequential) as int) payment_sequential,
            cast(trim(payment_type) as string) payment_type,
            cast(trim(payment_installments) as int) payment_installments,
            cast(trim(payment_value) as float) payment_value
        from source

    )
select *
from renamed
