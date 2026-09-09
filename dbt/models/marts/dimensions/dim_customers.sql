{{ config(materialized="view") }}

with
    source as (select * from {{ ref("stg_customers") }}),

    customer_state_dis as (
        select
            customer_state,
            count(distinct customer_id) as total_customers,
            count(distinct customer_unique_id) as total_unique_customers,
            rank() over (order by count(distinct customer_id) desc) as state_rank
        from source
        group by customer_state
    )

select *
from customer_state_dis
