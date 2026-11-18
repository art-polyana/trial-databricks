-- Клиенты с показателями по заказам: объём, открытая экспозиция, давность последнего заказа.
with order_stats as (
    select
        customer_hk,
        count(*)                                                as orders,
        count_if(is_open)                                       as open_orders,
        sum(order_amount)                                       as lifetime_order_amount,
        sum(case when is_open then order_amount else 0 end)     as open_exposure,
        min(order_date)                                         as first_order_date,
        max(order_date)                                         as last_order_date
    from {{ ref('stg_erp__orders') }}
    group by customer_hk
)

select
    c.customer_hk,
    c.customer_id,
    c.customer_name,
    c.market_segment,
    c.country_name,
    c.macro_region,
    c.credit_risk_tier,
    c.account_balance,
    coalesce(s.orders, 0)                                           as orders,
    coalesce(s.open_orders, 0)                                      as open_orders,
    coalesce(s.lifetime_order_amount, cast(0 as decimal(18, 2)))    as lifetime_order_amount,
    coalesce(s.open_exposure, cast(0 as decimal(18, 2)))            as open_exposure,
    s.first_order_date,
    s.last_order_date,
    s.customer_hk is not null                                       as has_orders,
    -- клиент с долгом по счёту и открытыми заказами — приоритет для кредитного контроля
    c.account_balance < 0 and coalesce(s.open_orders, 0) > 0        as is_risk_watchlist
from {{ ref('stg_erp__customers') }} c
left join order_stats s on c.customer_hk = s.customer_hk
