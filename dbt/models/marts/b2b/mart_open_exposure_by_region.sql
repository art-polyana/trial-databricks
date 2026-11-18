-- Открытая кредитная экспозиция (заказы в статусе Open) по регионам, странам и уровню риска.
with open_orders as (
    select *
    from {{ ref('fct_orders') }}
    where is_open
),

agg as (
    select
        macro_region,
        country_name,
        credit_risk_tier,
        count(*)                        as open_orders,
        count(distinct customer_hk)     as customers,
        sum(order_amount)               as open_exposure
    from open_orders
    group by macro_region, country_name, credit_risk_tier
)

select
    *,
    round(100 * open_exposure / sum(open_exposure) over (), 2) as exposure_share_pct
from agg
