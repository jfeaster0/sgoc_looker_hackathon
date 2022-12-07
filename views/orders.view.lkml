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
          WHEN ${created_date} >= DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -28 DAY)
          AND ${created_date} <= DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -28 DAY), INTERVAL 28 DAY)
          then 'Second Period'
          WHEN ${created_date} >= DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -56 DAY)
          AND ${created_date}  <= DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -56 DAY), INTERVAL 28 DAY)
          then 'First Period'
          END
    {% elsif pop_name._parameter_value == '7_over_7' %}
      CASE
          WHEN ${created_date} >= DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -7 DAY)
          AND ${created_date} <= DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -7 DAY), INTERVAL 7 DAY)
          then 'Second Period'
          WHEN ${created_date} >= DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -14 DAY)
          AND ${created_date}  <= DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -14 DAY), INTERVAL 7 DAY)
          then 'First Period'
          END
    {% elsif pop_name._parameter_value == 'dod' %}
      CASE
          WHEN ${created_date} >= DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -1 DAY)
          AND ${created_date} <= DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -1 DAY), INTERVAL 1 DAY)
          then 'Second Period'
          WHEN ${created_date} >= DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -2 DAY)
          AND ${created_date}  <= DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -1 DAY), INTERVAL 1 DAY)
          then 'First Period'
          END
    {% elsif pop_name._parameter_value == 'sdlw' %}
      CASE
          WHEN ${created_date} >= DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -1 DAY)
          AND ${created_date} <= DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -1 DAY), INTERVAL 1 DAY)
          then 'Second Period'
          WHEN ${created_date} >= DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -8 DAY)
          AND ${created_date}  <= DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -1 DAY), INTERVAL 1 DAY)
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




  dimension: days_from_start_first {
    hidden: yes
    type: number ## int equivlent
    sql:
    {% if pop_name._parameter_value == '28_over_28' %}
      DATE_DIFF('DAY',DATE_ADD('day', -56, CAST(DATE_TRUNC('DAY', NOW()) AS DATE)),CAST(${created_date} as DATE))
    {% elsif pop_name._parameter_value == '7_over_7' %}
      DATE_DIFF('DAY',DATE_ADD('day', -14, CAST(DATE_TRUNC('DAY', NOW()) AS DATE)),CAST(${created_date} as DATE))
    {% elsif pop_name._parameter_value == 'dod' %}
      DATE_DIFF('DAY', DATE_ADD('day', -2, CAST(DATE_TRUNC('DAY', NOW()) AS DATE)),CAST(${created_date} as DATE))
    {% elsif pop_name._parameter_value == 'yoy_qoq' %}
      DATE_DIFF('DAY',DATE_ADD('month',-15, CAST(DATE_TRUNC('quarter', NOW()) AS DATE)),CAST(${created_date} as DATE))
    {% elsif pop_name._parameter_value == 'sdlw' %}
      DATE_DIFF('DAY', DATE_ADD('day', -8, CAST(DATE_TRUNC('DAY', NOW()) AS DATE)),CAST(${created_date} as DATE))
    {% else %}
      DATE_DIFF('DAY', CAST({% date_start first_period_filter %} AS DATE),CAST(${created_date} as DATE))
    {% endif %} ;;
  }

  dimension: days_from_start_second {
    hidden: yes
    type: number ## int equivlent
    sql:
    {% if pop_name._parameter_value == 'yoy_qoq' %}
      DATE_DIFF('DAY',DATE_ADD('month',-3, CAST(DATE_TRUNC('quarter', NOW()) AS DATE)),CAST(${created_date} as DATE))
    {% elsif pop_name._parameter_value == '28_over_28' %}
      DATE_DIFF('DAY', DATE_ADD('day', -28, CAST(DATE_TRUNC('DAY', NOW()) AS DATE)),CAST(${created_date} as DATE))
    {% elsif pop_name._parameter_value == '7_over_7' %}
      DATE_DIFF('DAY', DATE_ADD('day', -7, CAST(DATE_TRUNC('DAY', NOW()) AS DATE)),CAST(${created_date} as DATE))
    {% elsif pop_name._parameter_value == 'dod' %}
      DATE_DIFF('DAY', DATE_ADD('day', -1, CAST(DATE_TRUNC('DAY', NOW()) AS DATE)),CAST(${created_date} as DATE))
    {% elsif pop_name._parameter_value == 'sdlw' %}
      DATE_DIFF('DAY', DATE_ADD('day', -1, CAST(DATE_TRUNC('DAY', NOW()) AS DATE)),CAST(${created_date} as DATE))
    {% else %}
      DATE_DIFF('DAY', CAST({% date_start second_period_filter %} AS DATE), CAST(${created_date} as DATE))
    {% endif %};;
  }

  dimension: days_from_first_period {
    group_label: "PoP"
    type: number
    sql:
      CASE
        WHEN ${days_from_start_second} >= 0 then ${days_from_start_second}+1
        when ${days_from_start_first} >= 0 then ${days_from_start_first}+1
      end;;
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
