- view: eme_job
  fields:

  - dimension: id
    primary_key: true
    type: int
    sql: ${TABLE}.ID

  - dimension: callback_token
    type: string
    sql: ${TABLE}.CALLBACK_TOKEN

  - dimension: callback_topic
    type: string
    sql: ${TABLE}.CALLBACK_TOPIC

  - dimension: canceled
    type: int
    sql: ${TABLE}.CANCELED

  - dimension: db
    type: string
    sql: ${TABLE}.DB

  - dimension: definition_bucket
    type: string
    sql: ${TABLE}.DEFINITION_BUCKET

  - dimension: failure_count
    type: int
    sql: ${TABLE}.FAILURE_COUNT

  - dimension: priority
    type: int
    sql: ${TABLE}.PRIORITY

  - dimension: q_chunk_count
    type: int
    sql: ${TABLE}.Q_CHUNK_COUNT

  - dimension: source
    type: string
    sql: ${TABLE}.SOURCE

  - dimension: state
    type: string
    sql: ${TABLE}.STATE

  - dimension: subtype
    type: string
    sql: ${TABLE}.SUBTYPE

  - dimension: superceded_by
    type: number
    sql: ${TABLE}.SUPERCEDED_BY

  - dimension: timestamp
    type: number
    sql: ${TABLE}.TIMESTAMP

  - dimension: type
    type: string
    sql: ${TABLE}.TYPE

  - measure: count
    type: count
    drill_fields: [id, eme_queue_chunk.count]

