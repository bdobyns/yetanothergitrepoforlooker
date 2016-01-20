- view: constraint_movingwall_all
  fields:

  - dimension: entitlement_id
    type: int
    sql: ${TABLE}.entitlementId

  - dimension: is_front
    type: string
    sql: ${TABLE}.isFront

  - dimension: value
    type: int
    sql: ${TABLE}.value

  - dimension: wall_unit
    type: string
    sql: ${TABLE}.wallUnit

  - measure: count
    type: count
    drill_fields: []

