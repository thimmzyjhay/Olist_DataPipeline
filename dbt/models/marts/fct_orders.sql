-- fct_orders.sql
{{ config(materialized="table") }}

select
    order_id,
    customer_id,
    order_status,
    order_status not in ('canceled', 'unavailable') as is_valid_order,
    cast(order_purchase_timestamp as date) as order_date,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    datediff(
        day, order_purchase_timestamp, order_delivered_customer_date
    ) as delivery_days,
    case
        when order_delivered_customer_date is null
        then null
        when order_delivered_customer_date > order_estimated_delivery_date
        then 1
        else 0
    end as late_delivery_flag
from {{ ref("orders_dedup") }}
