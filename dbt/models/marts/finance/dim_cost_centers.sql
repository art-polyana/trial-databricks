-- Центры затрат (ZIP) с накопленной статистикой транзакций.
with tx as (
    select
        cost_center_sk,
        count(*)                as transactions,
        sum(net_amount)         as net_amount,
        min(transaction_date)   as first_transaction_date,
        max(transaction_date)   as last_transaction_date
    from {{ ref('stg_billing__transactions') }}
    group by cost_center_sk
)

select
    cc.cost_center_sk,
    cc.zip_code,
    cc.cost_center_name,
    cc.tariff_tier,
    cc.vat_rate,
    coalesce(tx.transactions, 0)                        as transactions,
    coalesce(tx.net_amount, cast(0 as decimal(18, 2)))  as net_amount,
    tx.first_transaction_date,
    tx.last_transaction_date,
    tx.cost_center_sk is not null                       as has_transactions
from {{ ref('stg_billing__cost_centers') }} cc
left join tx on cc.cost_center_sk = tx.cost_center_sk
