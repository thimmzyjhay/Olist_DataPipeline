
  create or replace   view E_COMMERCE.gold.fct_order_reviews
  
  
  
  
  as (
    

with
    source as (select * from E_COMMERCE.silver.stg_order_reviews),

    review_summary as (
        select
            order_id,
            avg(review_score) as avg_review_score,
            count(review_id) as review_count,
            max(review_creation_date) as latest_review_date
        from source
        group by order_id
    ),

    review_latest as (
        select
            order_id,
            first_value(review_comment_message) over (
                partition by order_id order by review_creation_date desc
            ) as latest_review_comment
        from source
    )

select
    rs.order_id,
    rs.avg_review_score,
    rs.review_count,
    rs.latest_review_date,
    rl.latest_review_comment
from review_summary rs
left join review_latest rl on rs.order_id = rl.order_id
  );

