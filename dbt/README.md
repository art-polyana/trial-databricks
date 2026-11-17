# fin_controlling — dbt-проект

dbt-слой поверх пайплайна `fin_controlling` (Databricks Jobs). Пайплайн готовит bronze → silver → gold
в каталогах `fin_dev` / `fin_test` / `fin_prod`; dbt **читает** silver и quarantine и строит свои витрины
в отдельных схемах. Таблицы пайплайна dbt не изменяет: прав `MODIFY` у service principal dbt нет.

Coalesce-проект в корне репозитория не связан с dbt; dbt Cloud смотрит только в эту папку
(Project settings → Project subdirectory = `dbt`).

## Куда что пишется

| Слой | Схема | Материализация |
|---|---|---|
| `models/staging` | `<catalog>.dbt_staging` | view |
| `models/marts` | `<catalog>.dbt_marts` | table |
| `seeds` / `snapshots` | `dbt_seeds` / `dbt_snapshots` | — |

`<catalog>` берётся из переменной окружения dbt Cloud **`DBT_FIN_CATALOG`**:

| Окружение dbt Cloud | `DBT_FIN_CATALOG` |
|---|---|
| Project default (Development) | `fin_dev` |
| Deployment (Production) | `fin_prod` |
| Staging (если появится) | `fin_test` |

Источники (`models/staging/_sources.yml`) читаются из того же каталога, поэтому один и тот же код
работает в каждом окружении со своими данными. Имена схем фиксированы макросом
`macros/generate_schema_name.sql` (без склейки со схемой профиля).

## Модели

**Staging** — переименование колонок, деньги в `DECIMAL(18,2)`:
`stg_billing__transactions`, `stg_billing__cost_centers`, `stg_billing__rejected_trips`,
`stg_erp__orders`, `stg_erp__customers`.

**Marts / finance**
- `fct_daily_revenue` — выручка по дням × центр затрат × тариф, включая долю ручных проводок;
- `mart_cost_center_monthly` — месячный P&L, рост к прошлому месяцу и доля центра в выручке;
- `dim_cost_centers` — центры затрат (ZIP) с накопленной статистикой;
- `mart_dq_rejections_daily` — брак пайплайна по дням и причинам.

**Marts / b2b**
- `fct_orders` — заказы с атрибутами клиента (`Unknown`, если клиента нет);
- `dim_customers` — клиенты с открытой экспозицией и флагом `is_risk_watchlist`;
- `mart_open_exposure_by_region` — открытая экспозиция по регионам и уровням риска.

## Тесты
- `unique` / `not_null` на ключах, `accepted_values` на статусах и уровнях, `relationships`
  транзакции → центры затрат (error) и заказы → клиенты (**warn**: в данных v1 пайплайна до 73%
  заказов без клиента; после перехода пайплайна на `tpch_sf1` можно поднять до error);
- сверки в `tests/`: витрина выручки = транзакции, НДС + нетто = брутто, ни один заказ не потерян;
- freshness источников: предупреждение, если факты не обновлялись больше 48 часов
  (`dbt source freshness`).

## Запуск
Job в dbt Cloud: `dbt source freshness` (опционально) и `dbt build`.
