-- B2B-заказы ERP (TPC-H).
select
    order_hk,
    order_id,
    customer_hk,
    customer_id,
    order_date,
    order_status_code,
    order_status_desc,
    order_status_code = 'O'                     as is_open,
    order_priority,
    cast(gross_order_amount as decimal(18, 2))  as order_amount,
    updated_at
from {{ source('fin_silver', 'fact_b2b_orders') }}
