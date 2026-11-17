-- Брак по дням и причинам: сколько поездок и какая сумма не попала в выручку.
select
    trip_date,
    dq_failure_reason,
    count(*)            as rejected_trips,
    sum(gross_amount)   as rejected_gross_amount
from {{ ref('stg_billing__rejected_trips') }}
group by trip_date, dq_failure_reason
