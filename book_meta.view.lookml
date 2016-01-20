- view: book_meta
  fields:

  - dimension: account_externalid
    type: string
    sql: ${TABLE}.account_externalid

  - dimension: book_doi
    type: string
    sql: ${TABLE}.book_doi

  - dimension: customer_sitecode
    type: string
    sql: ${TABLE}.customer_sitecode

  - dimension: event_type
    type: string
    sql: ${TABLE}.event_type

  - dimension: license_subtype
    type: string
    sql: ${TABLE}.license_subtype

  - dimension_group: meta_timestamp
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.meta_timestamp

  - dimension: order_id
    type: string
    sql: ${TABLE}.order_id

  - measure: count
    type: count
    drill_fields: []

