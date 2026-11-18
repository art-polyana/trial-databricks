-- B2B-клиенты ERP (TPC-H).
select
    customer_hk,
    customer_id,
    customer_name,
    market_segment,
    country_name,
    macro_region,
    credit_risk_tier,
    cast(account_balance as decimal(18, 2))     as account_balance,
    updated_at
from {{ source('fin_silver', 'dim_b2b_customers') }}
