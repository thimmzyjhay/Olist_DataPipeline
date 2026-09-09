{{ config(materialized="view") }}

with
    source as (select * from {{ ref("stg_order_payments") }}),

    payments_metrics as (
        select
            order_id,
            payment_sequential,
            payment_type,
            sum(payment_value) over (partition by order_id) as total_payment_value,
            count(payment_sequential) over (partition by order_id) as payment_attempts,
            max(payment_installments) over (partition by order_id) as max_installments,
            count(distinct payment_type) over (
                partition by order_id
            ) as distinct_payment_types,
            first_value(payment_type) over (
                partition by order_id order by payment_sequential
            ) as first_payment_method
        from source
        qualify
            row_number() over (partition by order_id order by payment_sequential) = 1
    )

select
    order_id,
    total_payment_value,
    payment_attempts,
    max_installments,
    distinct_payment_types,
    first_payment_method
from payments_metrics
