- view: content_all
  fields:

  - dimension: doi
    type: string
    sql: ${TABLE}.doi

  - dimension: entitlement_id
    type: int
    sql: ${TABLE}.entitlementId

  - measure: count
    type: count
    drill_fields: []

