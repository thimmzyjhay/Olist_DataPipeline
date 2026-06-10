

WITH source AS (
    SELECT *
    FROM E_COMMERCE.silver.stg_products
),

product_metrics AS (
    SELECT
        product_category_name,
        COUNT(DISTINCT product_id) AS total_products,
        AVG(product_photos_qty) AS avg_photos_per_product,
        AVG(product_weight_g) AS avg_weight,
        AVG(product_length_cm) AS avg_length,
        AVG(product_height_cm) AS avg_height,
        AVG(product_width_cm) AS avg_width
    FROM source
    GROUP BY product_category_name
),

product_rank AS (
    SELECT
        product_category_name,
        total_products,
        avg_photos_per_product,
        avg_weight,
        avg_length,
        avg_height,
        avg_width,
        RANK() OVER (ORDER BY total_products DESC) AS category_rank
    FROM product_metrics
)

SELECT *
FROM product_rank