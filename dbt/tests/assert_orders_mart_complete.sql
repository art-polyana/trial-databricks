-- Ни один заказ не теряется в fct_orders: количество и сумма совпадают со staging.
with s as (
    select count(*) as cnt, sum(order_amount) as amt from {{ ref('stg_erp__orders') }}
),
m as (
    select count(*) as cnt, sum(order_amount) as amt from {{ ref('fct_orders') }}
)
select s.cnt, m.cnt as mart_cnt, s.amt, m.amt as mart_amt
from s cross join m
where s.cnt <> m.cnt or abs(s.amt - m.amt) > 0.01
