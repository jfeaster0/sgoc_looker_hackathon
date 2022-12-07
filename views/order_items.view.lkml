# The name of this view in Looker is "Order Items"
view: order_items {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: `demo.order_items`
    ;;
  drill_fields: [id]
  # This primary key is the unique key for this table in the underlying database.
  # You need to define a primary key in a view in order to join to other views.

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  # Here's what a typical dimension looks like in LookML.
  # A dimension is a groupable field that can be used to filter query results.
  # This dimension will be called "Inventory Item ID" in Explore.

  dimension: inventory_item_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: order_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.order_id ;;
  }

  dimension: returned_at {
    type: string
    sql: ${TABLE}.returned_at ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
  }

  # A measure is a field that uses a SQL aggregate function. Here are defined sum and average
  # measures for this dimension, but you can also add measures of many different aggregates.
  # Click on the type parameter to see all the options in the Quick Help panel on the right.

  measure: total_sale_price {
    type: sum
    sql: ${sale_price} ;;
  }

  measure: average_sale_price {
    type: average
    sql: ${sale_price} ;;
  }

  measure: count {
    type: count
    drill_fields: [id, inventory_items.id, orders.id]
  }
  ### Dynamic measure tool ###

  # for dynamic measure
  parameter: measure_selector {
    type: unquoted
    group_label: "Dynamic Measure"
    allowed_value: {
      label: "Total Sale Price"
      value: "total_sale_price"
    }
    allowed_value: {
      label: "Order Count"
      value: "orders.count"
    }
    allowed_value: {
      label: "Total Retail Price"
      value: "products.total_retail_price"
    }
  }

  measure: dynamic_test {
    label: "Filtered Measure"
    description: "use measure selector to pick measure"
    type: number
    ## value_format: "#,##0.00"
    sql:
          {% if measure_selector._parameter_value == 'total_sale_price' %}
           round(${sale_price},2)
          {% elsif measure_selector._parameter_value == 'orders.count' %}
           ${orders.count}
          {% elsif measure_selector._parameter_value == 'products.total_retail_price' %}
           round(${products.total_retail_price},2)
          {% endif %};;
    html:  {% if measure_selector._parameter_value == 'total_sale_price' %}
           ${{ rendered_value }}
          {% elsif measure_selector._parameter_value == 'orders.count' %}
           {{ rendered_value }}
           {% elsif measure_selector._parameter_value == 'products.total_retail_price' %}
           ${{ rendered_value }}
          {% endif %};;
  }
}
