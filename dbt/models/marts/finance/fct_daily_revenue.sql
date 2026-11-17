-- Выручка по дням: день × центр затрат × тарифный уровень.
select
    transaction_date,
    cost_center_name,
    tariff_tier,
    count(*)                                                    as transactions,
    count_if(is_manual_entry)                                   as manual_entries,
    sum(gross_amount)                                           as gross_amount,
    sum(vat_amount)                                             as vat_amount,
    sum(net_amount)                                             as net_amount,
    sum(case when is_manual_entry then gross_amount else 0 end) as manual_gross_amount,
    cast(sum(net_amount) / count(*) as decimal(18, 2))          as avg_net_ticket
from {{ ref('stg_billing__transactions') }}
group by transaction_date, cost_center_name, tariff_tier
