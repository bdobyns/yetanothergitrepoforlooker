- view: constraint_area_all
  fields:

  - dimension: area
    type: string
    sql: ${TABLE}.area

  - dimension: entitlement_id
    type: int
    sql: ${TABLE}.entitlementId

  - measure: count
    type: count
    drill_fields: []

