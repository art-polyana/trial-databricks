-- Месячный P&L по центрам затрат с динамикой месяц к месяцу и долей в общей выручке.
with monthly as (
    select
        date_trunc('MONTH', transaction_date)  as report_month,
        cost_center_name,
        sum(transactions)                      as transactions,
        sum(gross_amount)                      as gross_amount,
        sum(vat_amount)                        as vat_amount,
        sum(net_amount)                        as net_amount
    from {{ ref('fct_daily_revenue') }}
    group by 1, 2
),

with_prev as (
    select
        *,
        lag(net_amount) over (partition by cost_center_name order by report_month) as prev_net_amount,
        sum(net_amount) over (partition by report_month)                          as month_total_net
    from monthly
)

select
    cast(report_month as date)                                              as report_month,
    cost_center_name,
    transactions,
    gross_amount,
    vat_amount,
    net_amount,
    prev_net_amount,
    round(100 * (net_amount - prev_net_amount) / nullif(prev_net_amount, 0), 2) as net_mom_growth_pct,
    round(100 * net_amount / nullif(month_total_net, 0), 2)                    as net_share_pct
from with_prev
