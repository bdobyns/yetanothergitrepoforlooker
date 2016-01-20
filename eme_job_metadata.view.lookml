- view: eme_job_metadata
  fields:

  - dimension: id
    primary_key: true
    type: int
    sql: ${TABLE}.ID

  - dimension: job_id
    type: int
    sql: ${TABLE}.JOB_ID

  - dimension: message
    type: string
    sql: ${TABLE}.MESSAGE

  - dimension_group: timestamp
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.TIMESTAMP

  - dimension: type
    type: string
    sql: ${TABLE}.TYPE

  - dimension: value
    type: string
    sql: ${TABLE}.VALUE

  - measure: count
    type: count
    drill_fields: [id]

