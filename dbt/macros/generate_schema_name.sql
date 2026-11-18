{#-
  Схема берётся ровно из +schema (dbt_staging, dbt_marts, ...), без склейки со схемой профиля.
  Если +schema не задан, объект попадает в схему профиля (target.schema) — это сигнал,
  что модели не хватает конфигурации.
-#}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
