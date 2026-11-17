-- Заказы с атрибутами клиента. Заказы без клиента не теряются: атрибуты = 'Unknown'.
select
    o.order_hk,
    o.order_id,
    o.order_date,
    o.order_status_code,
    o.order_status_desc,
    o.is_open,
    o.order_priority,
    o.order_amount,
    o.customer_hk,
    o.customer_id,
    c.customer_hk is not null                   as has_customer,
    coalesce(c.customer_name, 'Unknown')        as customer_name,
    coalesce(c.market_segment, 'Unknown')       as market_segment,
    coalesce(c.country_name, 'Unknown')         as country_name,
    coalesce(c.macro_region, 'Unknown')         as macro_region,
    coalesce(c.credit_risk_tier, 'Unknown')     as credit_risk_tier
from {{ ref('stg_erp__orders') }} o
left join {{ ref('stg_erp__customers') }} c on o.customer_hk = c.customer_hk
