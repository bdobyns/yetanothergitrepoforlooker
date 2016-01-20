- view: temp_plants
  fields:

  - dimension: doi
    type: string
    sql: ${TABLE}.doi

  - dimension: iid
    type: string
    sql: ${TABLE}.iid

  - measure: count
    type: count
    drill_fields: []

