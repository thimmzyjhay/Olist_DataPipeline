{{ config(materialized="table") }}

with
    source as (select * from {{ source("ecommerce", "order_reviews") }}),

    renamed as (

        select
            cast(trim(review_id) as string) review_id,
            cast(trim(order_id) as string) order_id,
            cast(trim(review_score) as int) review_score,
            cast(trim(review_comment_title) as string) review_comment_title,
            cast(trim(review_comment_message) as string) review_comment_message,
            cast(trim(review_creation_date) as timestamp) review_creation_date,
            cast(trim(review_answer_timestamp) as timestamp) review_answer_timestamp
        from source

    )

select *
from renamed
