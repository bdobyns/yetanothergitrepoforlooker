- view: csp_meta
  fields:

  - dimension: account_externalid
    type: string
    sql: ${TABLE}.account_externalid

  - dimension: duration_no
    type: int
    sql: ${TABLE}.duration_no

  - dimension_group: end
    type: time
    timeframes: [date, week, month]
    convert_tz: false
    sql: ${TABLE}.end_date

  - dimension: event_type
    type: string
    sql: ${TABLE}.event_type

  - dimension: license_id
    type: string
    sql: ${TABLE}.license_id

  - dimension_group: meta_timestamp
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.meta_timestamp

  - dimension: offer_code
    type: string
    sql: ${TABLE}.offer_code

  - dimension: order_id
    type: string
    sql: ${TABLE}.order_id

  - dimension_group: start
    type: time
    timeframes: [date, week, month]
    convert_tz: false
    sql: ${TABLE}.start_date

  - measure: count
    type: count
    drill_fields: []

