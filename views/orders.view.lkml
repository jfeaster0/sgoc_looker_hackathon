# The name of this view in Looker is "Orders"
view: orders {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: `demo.orders`
    ;;
  drill_fields: [id]
  # This primary key is the unique key for this table in the underlying database.
  # You need to define a primary key in a view in order to join to other views.


  ## POP
  filter: first_period_filter {
    group_label: "PoP"
    type: date
  }

  filter: second_period_filter {
    group_label: "PoP"
    type: date
  }

  dimension: days_from_first_period {
    group_label: "Compare"
    type: string
    sql:
    {% if pop_name._parameter_value == 'yoy_qoq' %}
      CASE
        WHEN ${days_from_start_second} >= 0 THEN CAST(DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), MONTH)), INTERVAL -3 MONTH), INTERVAL ${days_from_start_second} DAY) AS DATE)
        WHEN ${days_from_start_first} >= 0 THEN CAST(DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), MONTH)), INTERVAL -3 MONTH), INTERVAL ${days_from_start_first} DAY) AS DATE)
      end
    {% elsif pop_name._parameter_value == '28_over_28' %}
      CASE
        WHEN ${days_from_start_second} >= 0 THEN CAST(DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -27 DAY), INTERVAL ${days_from_start_second} DAY) AS DATE)
        WHEN ${days_from_start_first} >= 0 THEN CAST(DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -27 DAY), INTERVAL ${days_from_start_first} DAY) AS DATE)
      end
    {% elsif pop_name._parameter_value == '7_over_7' %}
    CASE
        WHEN ${days_from_start_second} >= 0 THEN CAST(DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -6 DAY), INTERVAL ${days_from_start_second} DAY) AS DATE)
        WHEN ${days_from_start_first} >= 0 THEN CAST(DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -6 DAY), INTERVAL ${days_from_start_first} DAY) AS DATE)
      end
    {% elsif pop_name._parameter_value == 'dod' %}
    CASE
        WHEN ${days_from_start_second} >= 0 THEN CAST(DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL 0 DAY), INTERVAL ${days_from_start_second} DAY) AS DATE)
        WHEN ${days_from_start_first} >= 0 THEN CAST(DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL 0 DAY), INTERVAL ${days_from_start_first} DAY) AS DATE)
      end
    {% elsif pop_name._parameter_value == 'sdlw' %}
    CASE
        WHEN ${days_from_start_second} >= 0 THEN CAST(DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL 0 DAY), INTERVAL ${days_from_start_second} DAY) AS DATE)
        WHEN ${days_from_start_first} >= 0 THEN CAST(DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL 0 DAY), INTERVAL ${days_from_start_first} DAY) AS DATE)
      end
    {% else %}
      CASE
        WHEN ${days_from_start_second} >=  0 THEN CAST (DATETIME_ADD(CAST({% date_start second_period_filter %} AS DATE), INTERVAL ${days_from_start_second} DAY) as DATE)
        WHEN ${days_from_start_first} >= 0 THEN CAST( DATETIME_ADD(CAST({% date_start second_period_filter %} AS DATE), INTERVAL ${days_from_start_first} DAY) as DATE)
      end
    {% endif %}
      ;;
  }

  dimension: days_from_start_first {
    hidden: no
    type: number
    sql:
    {% if pop_name._parameter_value == 'yoy_qoq' %}
    DATE_DIFF( ${created_date},  CAST(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), MONTH)), INTERVAL -15 MONTH) as DATE) , DAY)
    {% elsif pop_name._parameter_value == '28_over_28' %}
    DATE_DIFF( ${created_date},  CAST(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -55 DAY) as DATE) , DAY)
    {% elsif pop_name._parameter_value == '7_over_7' %}
    DATE_DIFF( ${created_date},  CAST(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -13 DAY) as DATE) , DAY)
    {% elsif pop_name._parameter_value == 'dod' %}
    DATE_DIFF( ${created_date},  CAST(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -1 DAY) as DATE) , DAY)
    {% elsif pop_name._parameter_value == 'sdlw' %}
    DATE_DIFF( ${created_date},  CAST(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -7 DAY) as DATE) , DAY)
    {% else %}
    DATE_DIFF( ${created_date},CAST({% date_start first_period_filter %} AS DATE), DAY)
    {% endif %}
    ;;

  }

  dimension: days_from_start_second {
    hidden: no
    type: number
    sql:
    {% if pop_name._parameter_value == 'yoy_qoq' %}
    DATE_DIFF( ${created_date},  CAST(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), MONTH)), INTERVAL -3 MONTH) as DATE) , DAY)
    {% elsif pop_name._parameter_value == '28_over_28' %}
    DATE_DIFF( ${created_date},  CAST(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -27 DAY) as DATE) , DAY)
    {% elsif pop_name._parameter_value == '7_over_7' %}
    DATE_DIFF( ${created_date},  CAST(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -6 DAY) as DATE) , DAY)
    {% elsif pop_name._parameter_value == 'dod' %}
    DATE_DIFF( ${created_date},  CAST(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL 0 DAY) as DATE) , DAY)
    {% elsif pop_name._parameter_value == 'sdlw' %}
    DATE_DIFF( ${created_date},  CAST(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL 0 DAY) as DATE) , DAY)
    {% else %}
    DATE_DIFF( ${created_date}, CAST({% date_start second_period_filter %} AS DATE), DAY)
    {% endif %}
    ;;
  }

   parameter: pop_name {
    type: unquoted
    group_label: "PoP"
    allowed_value: {
      label: "Quarter over Prior Year Quarter"
      value: "yoy_qoq"
    }
    allowed_value: {
      label: "28 over 28"
      value: "28_over_28"
    }
    allowed_value: {
      label: "7 over 7"
      value: "7_over_7"
    }
    allowed_value: {
      label: "DoD"
      value: "dod"
    }
    allowed_value: {
      label: "Same Day Last Week"
      value: "sdlw"
    }
  }

  dimension: period_selected {
    group_label: "PoP"
    sql:
    {% if pop_name._parameter_value == 'yoy_qoq' %}
      CASE
          WHEN ${created_date} >= DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), MONTH)), INTERVAL -3 MONTH)
          AND ${created_date} <= DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), MONTH)), INTERVAL -3 MONTH), INTERVAL 3 MONTH)
          then 'Second Period'
          WHEN ${created_date} >= DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), MONTH)), INTERVAL -15 MONTH)
          AND ${created_date}  <= DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), MONTH)), INTERVAL -15 MONTH), INTERVAL 3 MONTH)
          then 'First Period'
          END
    {% elsif pop_name._parameter_value == '28_over_28' %}
      CASE
          WHEN ${created_date} >= DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -27 DAY)
          AND ${created_date} <= DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -27 DAY), INTERVAL 28 DAY)
          then 'Second Period'
          WHEN ${created_date} >= DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -55 DAY)
          AND ${created_date}  <= DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -55 DAY), INTERVAL 28 DAY)
          then 'First Period'
          END
    {% elsif pop_name._parameter_value == '7_over_7' %}
      CASE
          WHEN ${created_date} >= DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -6 DAY)
          AND ${created_date} <= DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -6 DAY), INTERVAL 7 DAY)
          then 'Second Period'
          WHEN ${created_date} >= DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -13 DAY)
          AND ${created_date}  <= DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -13 DAY), INTERVAL 7 DAY)
          then 'First Period'
          END
    {% elsif pop_name._parameter_value == 'dod' %}
      CASE
          WHEN ${created_date} >= DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL 0 DAY)
          AND ${created_date} <= DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL 0 DAY), INTERVAL 1 DAY)
          then 'Second Period'
          WHEN ${created_date} >= DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -1 DAY)
          AND ${created_date}  <= DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL 0 DAY), INTERVAL 1 DAY)
          then 'First Period'
          END
    {% elsif pop_name._parameter_value == 'sdlw' %}
      CASE
          WHEN ${created_date} >= DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL 0 DAY)
          AND ${created_date} <= DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL 0 DAY), INTERVAL 1 DAY)
          then 'Second Period'
          WHEN ${created_date} >= DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -7 DAY)
          AND ${created_date}  <= DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -8 DAY), INTERVAL 1 DAY)
          then 'First Period'
          END
    {% else %}
      CASE
          WHEN ${created_date}  >= CAST( {% date_start first_period_filter %} as DATE)
          AND ${created_date}<= CAST( {% date_end first_period_filter %} as DATE)
          then 'First Period'
          WHEN ${created_date} >= CAST( {% date_start second_period_filter%} as DATE)
          AND ${created_date}  <= CAST ({% date_end second_period_filter %} as DATE)
          then 'Second Period'
          END
    {% endif %}
    ;;
  }

  ## End PoP
  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  # Here's what a typical dimension looks like in LookML.
  # A dimension is a groupable field that can be used to filter query results.
  # This dimension will be called "Campaign" in Explore.

  dimension: campaign {
    type: string
    sql: ${TABLE}.campaign ;;
  }

  # Dates and timestamps can be represented in Looker using a dimension group of type: time.
  # Looker converts dates and timestamps to the specified timeframes within the dimension group.

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  measure: count {
    type: count
    drill_fields: [id, users.last_name, users.id, users.first_name, order_items.count]
  }
}
