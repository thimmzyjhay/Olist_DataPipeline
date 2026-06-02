{{ config(materialized='view') }}

WITH source AS (
    SELECT *
    FROM {{ source('ecommerce', 'stg_customers') }}
),

customer_city_dis AS (
    SELECT
        customer_state,
        customer_city,
        COUNT(DISTINCT customer_id) AS customers_per_city,
        COUNT(DISTINCT customer_unique_id) AS unique_customers_per_city
    FROM source
    GROUP BY customer_state, customer_city
),

customer_state_dis AS (
    SELECT
        customer_state,
        SUM(customers_per_city) AS total_customers,
        SUM(unique_customers_per_city) AS total_unique_customers,
        RANK() OVER (ORDER BY SUM(customers_per_city) DESC) AS state_rank
    FROM customer_city_dis
    GROUP BY customer_state
)

SELECT *
FROM customer_state_dis;
