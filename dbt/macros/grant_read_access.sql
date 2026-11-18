{#-
  Схемы dbt_* создаёт и владеет ими service principal dbt, поэтому остальные пользователи
  (включая владельца каталога) их по умолчанию не видят. После каждого запуска выдаём
  читателям USE SCHEMA + SELECT на схемы, куда dbt что-то построил в этом запуске.
  Список читателей — var('reader_principals') в dbt_project.yml.
-#}
{% macro grant_read_access(results) %}
    {% if execute %}
        {% set schemas = [] %}
        {% for res in results %}
            {% set node = res.node %}
            {% if node.resource_type in ['model', 'seed', 'snapshot'] and res.status in ['success', 'pass'] %}
                {% set fq = '`' ~ node.database ~ '`.`' ~ node.schema ~ '`' %}
                {% if fq not in schemas %}
                    {% do schemas.append(fq) %}
                {% endif %}
            {% endif %}
        {% endfor %}
        {% for schema in schemas %}
            {% for principal in var('reader_principals', []) %}
                {% do run_query('GRANT USE SCHEMA, SELECT ON SCHEMA ' ~ schema ~ ' TO `' ~ principal ~ '`') %}
                {% do log('Granted USE SCHEMA, SELECT on ' ~ schema ~ ' to ' ~ principal, info=true) %}
            {% endfor %}
        {% endfor %}
    {% endif %}
{% endmacro %}
