-- fct_order_reviews.sql
{{ config(materialized="table") }}

select
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
from {{ ref("order_reviews_dedup") }}
