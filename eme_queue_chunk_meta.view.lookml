- view: eme_queue_chunk_meta
  fields:

  - dimension: id
    primary_key: true
    type: int
    sql: ${TABLE}.ID

  - dimension: chunk_id
    type: string
    sql: ${TABLE}.CHUNK_ID

  - dimension_group: date_created
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.DATE_CREATED

  - dimension: description
    type: string
    sql: ${TABLE}.DESCRIPTION

  - dimension: metatype
    type: string
    sql: ${TABLE}.METATYPE

  - measure: count
    type: count
    drill_fields: [id]

