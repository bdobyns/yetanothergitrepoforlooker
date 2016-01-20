- view: jpass_meta
  fields:

  - dimension: account_externalid
    type: string
    sql: ${TABLE}.account_externalid

  - dimension: article_doi
    type: string
    sql: ${TABLE}.article_doi

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

  - dimension: user_name
    type: string
    sql: ${TABLE}.user_name

  - measure: count
    type: count
    drill_fields: [user_name]

