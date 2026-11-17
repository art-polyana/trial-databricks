-- Транзакции биллинга: единые имена колонок, деньги в DECIMAL(18,2).
-- is_manual_entry = строка внесена вручную (не из системы биллинга ERP_BILLING_NY).
select
    transaction_hk,
    transaction_date,
    tpep_pickup_datetime                        as pickup_at,
    tpep_dropoff_datetime                       as dropoff_at,
    pickup_zip,
    dropoff_zip,
    trip_distance,
    duration_minutes,
    cost_center_sk,
    cost_center_name,
    tariff_tier,
    vat_rate,
    cast(fare_amount as decimal(18, 2))         as gross_amount,
    cast(vat_amount as decimal(18, 2))          as vat_amount,
    cast(net_revenue as decimal(18, 2))         as net_amount,
    _source_system                              as source_system,
    _source_system <> 'ERP_BILLING_NY'          as is_manual_entry,
    updated_at
from {{ source('fin_silver', 'fact_financial_transactions') }}
