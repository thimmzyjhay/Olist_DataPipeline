{{ config(materialized="table") }}

with
    dates as (
        {{
            dbt_utils.date_spine(
                datepart="day",
                start_date="cast('2016-01-01' as date)",
                end_date="cast('2019-01-01' as date)",
            )
        }}
    )

select
    cast(date_day as date) as date_key,
    year(date_day) as year,
    quarter(date_day) as quarter,
    month(date_day) as month,
    monthname(date_day) as month_name,
    dayofweek(date_day) as day_of_week,
    dayname(date_day) as day_name,
    dayofweek(date_day) in (0, 6) as is_weekend
from dates
