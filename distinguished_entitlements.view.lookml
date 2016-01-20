- view: distinguished_entitlements
  fields:

  - dimension: code
    type: string
    sql: ${TABLE}.code

  - dimension: content_type
    type: string
    sql: ${TABLE}.contentType

  - dimension: context
    type: string
    sql: ${TABLE}.context

  - dimension: entitlement_id
    type: int
    sql: ${TABLE}.entitlementId

  - dimension: entitlement_type
    type: string
    sql: ${TABLE}.entitlementType

  - measure: count
    type: count
    drill_fields: []

