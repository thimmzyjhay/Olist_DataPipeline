-- rpt_category_performance
{{ config(materialized="table") }}

with
    reviews as (
        select order_id, avg(review_score) as review_score
        from {{ ref("fct_order_reviews") }}
        group by order_id
    )

select
    coalesce(p.product_category_name_english, 'unknown') as product_category,
    count(distinct i.order_id) as total_orders,
    count(*) as items_sold,
    round(sum(i.price), 2) as revenue,
    round(sum(i.price) / sum(sum(i.price)) over (), 4) as revenue_share,
    round(avg(i.price), 2) as avg_item_price,
    round(avg(o.late_delivery_flag), 4) as late_delivery_rate,
    round(avg(r.review_score), 2) as avg_review_score,
    rank() over (order by sum(i.price) desc) as revenue_rank
from {{ ref("fct_order_items") }} i
join {{ ref("fct_orders") }} o on i.order_id = o.order_id
left join {{ ref("dim_products") }} p on i.product_id = p.product_id
left join reviews r on i.order_id = r.order_id
where o.is_valid_order
group by 1
