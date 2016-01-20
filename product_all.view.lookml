- view: product_all
  fields:

  - dimension: id
    primary_key: true
    type: int
    sql: ${TABLE}.id

  - dimension: contentid
    type: int
    sql: ${TABLE}.contentid

  - dimension: entitlement_id
    type: int
    sql: ${TABLE}.entitlementId

  - dimension: name
    type: string
    sql: ${TABLE}.name

  - dimension: offer_code
    type: string
    sql: ${TABLE}.offerCode

  - measure: count
    type: count
    drill_fields: [id, name]

