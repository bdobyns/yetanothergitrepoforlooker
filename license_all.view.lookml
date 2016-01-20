- view: license_all
  fields:

  - dimension: id
    primary_key: true
    type: int
    sql: ${TABLE}.id

  - dimension: description
    type: string
    sql: ${TABLE}.description

  - dimension_group: end
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.endDate

  - dimension: entitlement_id
    type: int
    sql: ${TABLE}.entitlementId

  - dimension: license_type
    type: string
    sql: ${TABLE}.licenseType

  - dimension: offer_id
    type: int
    sql: ${TABLE}.offerId

  - dimension: product_id
    type: int
    sql: ${TABLE}.productId

  - dimension_group: start
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.startDate

  - dimension: user_id
    type: int
    # hidden: true
    sql: ${TABLE}.userId

  - measure: count
    type: count
    drill_fields: [id, users.id]

