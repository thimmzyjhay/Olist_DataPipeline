{{ config(materialized="view") }}

with
    source as (select * from {{ ref("stg_sellers") }}),

    seller_state_dis as (
        select
            seller_state,
            count(distinct seller_id) as total_sellers,
            rank() over (order by count(distinct seller_id) desc) as state_rank
        from source
        group by seller_state
    )

select *
from seller_state_dis
