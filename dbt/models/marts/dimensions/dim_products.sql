{{ config(materialized="view") }}

select
    product_category_name,
    count(distinct product_id) as total_products,
    avg(product_photos_qty) as avg_photos_per_product,
    avg(product_weight_g) as avg_weight,
    avg(product_length_cm) as avg_length,
    avg(product_height_cm) as avg_height,
    avg(product_width_cm) as avg_width,
    rank() over (order by count(distinct product_id) desc) as category_rank
from {{ ref("stg_products") }}
group by product_category_name
