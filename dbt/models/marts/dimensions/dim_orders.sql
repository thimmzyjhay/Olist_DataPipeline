{{ config(materialized="view") }}

select
    count(distinct order_id) as total_orders,
    avg(
        datediff(day, order_purchase_timestamp, order_delivered_customer_date)
    ) as avg_delivery_time,
    sum(
        datediff(day, order_purchase_timestamp, order_delivered_customer_date)
    ) as total_delivery_time,
    avg(datediff(day, order_purchase_timestamp, order_approved_at)) as avg_approval_lag,
    sum(
        case
            when order_delivered_customer_date > order_estimated_delivery_date
            then 1
            else 0
        end
    ) as late_orders
from {{ ref("stg_orders") }}
