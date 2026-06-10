

WITH source AS (
    SELECT *
    FROM E_COMMERCE.silver.stg_sellers
),

seller_city_dis AS (
    SELECT 
        seller_state,
        seller_city,
        COUNT(DISTINCT seller_id) AS sellers_per_city
    FROM source
    GROUP BY seller_state, seller_city
),

seller_state_dis AS (
    SELECT 
        seller_state,
        SUM(sellers_per_city) AS total_sellers,
        RANK() OVER (ORDER BY SUM(sellers_per_city) DESC) AS state_rank
    FROM seller_city_dis
    GROUP BY seller_state
)

SELECT *
FROM seller_state_dis