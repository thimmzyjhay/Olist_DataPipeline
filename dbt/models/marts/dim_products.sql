{{ config(materialized="view") }}

select
    p.product_id,
    p.product_category_name,
    coalesce(
        t.product_category_name_english, p.product_category_name, 'unknown'
    ) as product_category_name_english,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
from {{ ref("products_dedup") }} p
left join
    {{ ref("stg_product_category_translation") }} t
    on p.product_category_name = t.product_category_name
