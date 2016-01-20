- view: combo_entitlement_all
  fields:

  - dimension: combined_id
    type: int
    sql: ${TABLE}.combinedId

  - dimension: entitlement_id
    type: int
    sql: ${TABLE}.entitlementId

  - dimension: is_and_not
    type: string
    sql: ${TABLE}.isAndNot

  - measure: count
    type: count
    drill_fields: []

