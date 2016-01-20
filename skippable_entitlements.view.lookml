- view: skippable_entitlements
  fields:

  - dimension: id
    primary_key: true
    type: int
    sql: ${TABLE}.id

  - measure: count
    type: count
    drill_fields: [id]

