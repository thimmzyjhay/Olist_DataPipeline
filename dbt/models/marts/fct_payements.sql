-- fct_order_payments.sql
{{ config(materialized="table") }}

select order_id, payment_sequential, payment_type, payment_installments, payment_value
from {{ ref("order_payments_dedup") }}
