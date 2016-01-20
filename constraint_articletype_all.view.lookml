- view: constraint_articletype_all
  fields:

  - dimension: entitlement_id
    type: int
    sql: ${TABLE}.entitlementId

  - dimension: include
    type: string
    sql: ${TABLE}.include

  - measure: count
    type: count
    drill_fields: []

