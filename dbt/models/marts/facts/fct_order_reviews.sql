{{ config(materialized="view") }}

with
    source as (select * from {{ ref("stg_order_reviews") }}),

    review_metrics as (
        select
            order_id,
            review_creation_date,
            avg(review_score) over (partition by order_id) as avg_review_score,
            count(review_id) over (partition by order_id) as review_count,
            max(review_creation_date) over (
                partition by order_id
            ) as latest_review_date,
            first_value(review_comment_message) over (
                partition by order_id order by review_creation_date desc
            ) as latest_review_comment
        from source
        qualify
            row_number() over (partition by order_id order by review_creation_date desc)
            = 1
    )

select
    order_id, avg_review_score, review_count, latest_review_date, latest_review_comment
from review_metrics
