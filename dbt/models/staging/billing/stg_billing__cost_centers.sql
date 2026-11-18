-- Текущие версии центров затрат (одна строка на ZIP).
select
    cost_center_sk,
    zip_code,
    cost_center_name,
    tariff_tier,
    vat_rate,
    valid_from
from {{ source('fin_silver', 'dim_cost_centers') }}
where is_current
