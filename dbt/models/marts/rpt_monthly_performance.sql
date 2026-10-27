{{ config(materialized="table") }}

with
    reviews as (
        select order_id, avg(review_score) as review_score
        from {{ ref("fct_order_reviews") }}
        group by order_id
    ),

    orders_by_month as (
        select
            d.year,
            d.month,
            d.month_name,
            count(*) as total_orders,
            round(avg(o.delivery_days), 1) as avg_delivery_days,
            round(avg(o.late_delivery_flag), 4) as late_delivery_rate,
            round(avg(r.review_score), 2) as avg_review_score
        from {{ ref("fct_orders") }} o
        join {{ ref("dim_date") }} d on o.order_date = d.date_key
        left join reviews r on o.order_id = r.order_id
        where o.is_valid_order
        group by 1, 2, 3
    ),

    revenue_by_month as (
        select
            d.year,
            d.month,
            round(sum(i.price), 2) as revenue,
            round(sum(i.freight_value), 2) as freight
        from {{ ref("fct_order_items") }} i
        join {{ ref("fct_orders") }} o on i.order_id = o.order_id
        join {{ ref("dim_date") }} d on o.order_date = d.date_key
        where o.is_valid_order
        group by 1, 2
    )

select
    m.year,
    m.month,
    m.month_name,
    m.total_orders,
    r.revenue,
    r.freight,
    round(r.revenue / m.total_orders, 2) as avg_order_value,
    m.avg_delivery_days,
    m.late_delivery_rate,
    m.avg_review_score
from orders_by_month m
left join revenue_by_month r on m.year = r.year and m.month = r.month
order by m.year, m.month
