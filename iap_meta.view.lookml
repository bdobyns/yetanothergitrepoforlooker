- view: iap_meta
  fields:

  - dimension: account_externalid
    type: string
    sql: ${TABLE}.account_externalid

  - dimension: email
    type: string
    sql: ${TABLE}.email

  - dimension_group: expiration
    type: time
    timeframes: [date, week, month]
    convert_tz: false
    sql: ${TABLE}.expiration_date

  - dimension_group: last_updated
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.last_updated

  - dimension: license_externalid
    type: string
    sql: ${TABLE}.license_externalid

  - dimension: member_id
    type: string
    sql: ${TABLE}.member_id

  - dimension: offer_code
    type: string
    sql: ${TABLE}.offer_code

  - dimension: provider
    type: string
    sql: ${TABLE}.provider

  - dimension: status
    type: string
    sql: ${TABLE}.status

  - dimension: uuid
    type: string
    sql: ${TABLE}.uuid

  - measure: count
    type: count
    drill_fields: []

