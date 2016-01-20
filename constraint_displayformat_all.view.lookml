- view: constraint_displayformat_all
  fields:

  - dimension: entitlement_id
    type: int
    sql: ${TABLE}.entitlementId

  - dimension: format
    type: string
    sql: ${TABLE}.format

  - measure: count
    type: count
    drill_fields: []

