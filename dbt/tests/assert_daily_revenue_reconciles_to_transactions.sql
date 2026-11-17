-- Сверка: итоги fct_daily_revenue совпадают с транзакциями (количество и суммы). Возвращает строку при расхождении.
with tx as (
    select count(*) as cnt, sum(gross_amount) as gross, sum(net_amount) as net
    from {{ ref('stg_billing__transactions') }}
),
mart as (
    select sum(transactions) as cnt, sum(gross_amount) as gross, sum(net_amount) as net
    from {{ ref('fct_daily_revenue') }}
)
select tx.cnt, mart.cnt as mart_cnt, tx.gross, mart.gross as mart_gross, tx.net, mart.net as mart_net
from tx cross join mart
where tx.cnt <> mart.cnt
   or abs(tx.gross - mart.gross) > 0.01
   or abs(tx.net - mart.net) > 0.01
