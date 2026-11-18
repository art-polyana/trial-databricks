-- Поездки из карантина пайплайна (не прошли DQ-правила).
select
    transaction_hk,
    dq_failure_reason,
    cast(tpep_pickup_datetime as date)          as trip_date,
    pickup_zip,
    cast(fare_amount as decimal(18, 2))         as gross_amount,
    trip_distance,
    quarantined_at
from {{ source('fin_quarantine', 'erp_trips_rejected') }}
