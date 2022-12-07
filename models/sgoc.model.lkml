# Define the database connection to be used for this model.
connection: "lookerdata"

# include all the views
include: "/views/**/*.view"


datagroup: sgoc_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: sgoc_default_datagroup



explore: order_items {
  sql_always_where:
  {% if orders.pop_name._parameter_value == 'yoy_qoq' %}
    (
    CAST( ${orders.created_date} as DATE) >= DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), MONTH)), INTERVAL -3 MONTH)
    AND
    CAST( ${orders.created_date} as DATE)<= DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), MONTH)), INTERVAL -3 MONTH), INTERVAL 3 MONTH)
    )
    or
    (
    CAST( ${orders.created_date} as DATE) >= DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), MONTH)), INTERVAL -15 MONTH)
    AND
    CAST( ${orders.created_date} as DATE) <= DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), MONTH)), INTERVAL -15 MONTH), INTERVAL 3 MONTH)
    )


  {% elsif orders.pop_name._parameter_value == '28_over_28' %}
    (
    CAST( ${orders.created_date} as DATE) >= DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -27 DAY)
    AND
    CAST( ${orders.created_date} as DATE)<= DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -27 DAY), INTERVAL 28 DAY)
    )
    or
    (
    CAST( ${orders.created_date} as DATE) >= DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -55 DAY)
    AND
    CAST( ${orders.created_date} as DATE) <= DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -55 DAY), INTERVAL 28 DAY)
    )
  {% elsif orders.pop_name._parameter_value == '7_over_7' %}
   (
    CAST( ${orders.created_date} as DATE) >= DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -6 DAY)
    AND
    CAST( ${orders.created_date} as DATE)<= DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -6 DAY), INTERVAL 7 DAY)
    )
    or
    (
    CAST( ${orders.created_date} as DATE) >= DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -13 DAY)
    AND
    CAST( ${orders.created_date} as DATE) <= DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -13 DAY), INTERVAL 7 DAY)
    )
  {% elsif orders.pop_name._parameter_value == 'dod' %}
   (
    CAST( ${orders.created_date} as DATE) >= DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL 0 DAY)
    AND
    CAST( ${orders.created_date} as DATE)<= DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL 0 DAY), INTERVAL 1 DAY)
    )
    or
    (
    CAST( ${orders.created_date} as DATE) >= DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -7 DAY)
    AND
    CAST( ${orders.created_date} as DATE) <= DATETIME_ADD(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP('2017-03-25 00:00:00'), DAY)), INTERVAL -8 DAY), INTERVAL 1 DAY)
    )

  {% elsif orders.first_period_filter._in_query %}
    (
    CAST(${orders.created_date} as DATE) >= CAST({% date_start orders.first_period_filter %} as DATE)
    AND
    CAST(${orders.created_date} as DATE)< Cast({% date_end orders.first_period_filter %} as DATE)
    )
    or
    (
    CAST(${orders.created_date} as DATE) >= CAST({% date_start orders.second_period_filter %} as DATE)
    AND
    CAST(${orders.created_date} as DATE) < Cast({% date_end orders.second_period_filter %} as DATE)
    )
  {% endif %}
  ;;
  join: inventory_items {
    type: left_outer
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    relationship: many_to_one

  }

  join: orders {
    type: left_outer
    sql_on: ${order_items.order_id} = ${orders.id} ;;
    relationship: many_to_one
  }

  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }

  join: users {
    type: left_outer
    sql_on: ${orders.user_id} = ${users.id} ;;
    relationship: many_to_one
  }
}

# To create more sophisticated Explores that involve multiple views, you can use the join parameter.
# Typically, join parameters require that you define the join type, join relationship, and a sql_on clause.
# Each joined view also needs to define a primary key.

explore: users {}

explore: products {}

explore: inventory_items {
  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }
}

explore: product_sheets {
  join: products {
    type: left_outer
    sql_on: ${product_sheets.product_id} = ${products.id} ;;
    relationship: many_to_one
  }
}
