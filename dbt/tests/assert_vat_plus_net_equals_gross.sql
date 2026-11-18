-- Каждая транзакция: НДС + нетто = брутто (допуск 1 цент на округление).
select transaction_hk, gross_amount, vat_amount, net_amount
from {{ ref('stg_billing__transactions') }}
where abs(vat_amount + net_amount - gross_amount) > 0.01
