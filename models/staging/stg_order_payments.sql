{{
    config(materilized='view')
}}

with source as (
    SELECT *
    FROM {{source('ecommerce', 'order_payments')}}
)

renamed as (

    select
        order_id,
        payment_sequential,
        payment_type,
        payment_installments,
        payment_value
    from source

)
select * from renamed