- view: constraint_fixedwall_walldate_all
  fields:

  - dimension: entitlement_id
    type: int
    sql: ${TABLE}.entitlementId

  - dimension: is_front
    type: string
    sql: ${TABLE}.isFront

  - dimension_group: wall
    type: time
    timeframes: [date, week, month]
    convert_tz: false
    sql: ${TABLE}.wallDate

  - measure: count
    type: count
    drill_fields: []

