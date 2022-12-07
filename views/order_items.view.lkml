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
      label: "Count of Order"
      value: "orders.count"
    }
    allowed_value: {
      label: "Total Retail Price"
      value: "products.total_retail_price"
    }
  }

  measure: filtered_measure {
    label_from_parameter: measure_selector
    description: "use measure selector to pick measure"
    type: number
    ## value_format: "#,##0.00"
    sql:
          {% if measure_selector._parameter_value == 'total_sale_price' %}
           ${total_sale_price}
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

## delta work
  parameter: delta_picker {
    type: unquoted
    group_label: "Compare"
    allowed_value: {
      label: "% Delta"
      value: "prc_change"
    }
    allowed_value: {
      label: "Delta"
      value: "change"
    }
    allowed_value: {
      label: "Absolute Delta"
      value: "abs_change"
    }
  }

  measure: delta {
    group_label: "Compare"
    description: "delta calculation, pick with delta picker"
    type: number
    sql:
    {%if delta_picker._parameter_value == 'change' %}
    CASE WHEN ${orders.period_selected} = 'Second Period' THEN round(${delta_value} ,2) else null end
    {% elsif delta_picker._parameter_value == 'prc_change' %}
    CASE WHEN ${orders.period_selected} = 'Second Period' THEN round(${delta_prc}*100,2) else null end
    {% elsif delta_picker._parameter_value == 'abs_change' %}
    CASE WHEN ${orders.period_selected} = 'Second Period' THEN round(${abs_delta_value},2) else null end
    {% endif %}
    ;;
    html:  {% if delta_picker._parameter_value == 'change' %}
          {{ rendered_value }}
          {% elsif delta_picker._parameter_value == 'prc_change' %}
          {{ rendered_value }} %
          {% elsif delta_picker._parameter_value == 'abs_change' %}
          {{ rendered_value }}
          {% endif %};;
  }


  measure: total_filtered_measure {
    group_label: "Compare"
    description: "This generates the denomanator for most Delta calculations, not those that are compound metrics e.g eCPM"
    hidden: yes
    type: number
    sql:
    {% if measure_selector._parameter_value == 'total_sale_price' %}
      sum(${total_sale_price})
    {% elsif measure_selector._parameter_value == 'orders.count' %}
      sum(${orders.count})
    {% elsif measure_selector._parameter_value == 'products.total_retail_price' %}
      sum(${products.total_retail_price})
    {% else %}
    "ERROR Message - Missing total cacluation for the delta, measure: total_filtered_measure"
    {% endif %};;
    }


  measure: delta_value {
    group_label: "Compare"
    description: "delta value, not percentage"
    type: number
    sql:
    ${filtered_measure} - (${total_filtered_measure} - ${filtered_measure})

  dimension: in_query_testing {
    group_label: "Compare"
    type: string
    hidden: yes
    sql:
        PARTITION by
        {%if order_items.id._is_selected %}
        ${id},
        {%endif%}
        {%if order_items.inventory_item_id._is_selected %}
        ${inventory_item_id},
        {%endif%}
        {%if order_items.order_id._is_selected %}
        ${order_id},
        {%endif%}
        {%if order_items.returned_at._is_selected %}
        ${returned_at},
        {%endif%}
        {%if order_items.sale_price._is_selected %}
        ${sale_price},
        {%endif%}
        {% if true %}
        1
        {% endif %}

      ;;
  }

  measure: delta_prc {
    group_label: "Compare"
    description: "Percent Change from First Period to Second Period"
    type: number
    value_format_name: percent_2
    sql: (${filtered_measure} - (${total_filtered_measure} - ${filtered_measure}))/(${total_filtered_measure} - ${filtered_measure});;
    }

  measure: abs_delta_value {
    group_label: "Compare"
    description: "Absolute Change from First Period to Second Period"
    type: number
    sql: abs(${delta_value});;
  }


}
