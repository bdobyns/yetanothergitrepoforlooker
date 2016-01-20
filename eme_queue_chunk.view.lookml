- view: eme_queue_chunk
  fields:

  - dimension: id
    primary_key: true
    type: int
    sql: ${TABLE}.ID

  - dimension: batch_id
    type: string
    sql: ${TABLE}.BATCH_ID

  - dimension: chunk_idx
    type: int
    sql: ${TABLE}.CHUNK_IDX

  - dimension: chunk_total
    type: int
    sql: ${TABLE}.CHUNK_TOTAL

  - dimension_group: date_cancelled
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.DATE_CANCELLED

  - dimension_group: date_created
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.DATE_CREATED

  - dimension_group: date_failed
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.DATE_FAILED

  - dimension_group: date_started
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.DATE_STARTED

  - dimension_group: date_success
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.DATE_SUCCESS

  - dimension: db
    type: string
    sql: ${TABLE}.DB

  - dimension: eme_job_id
    type: int
    # hidden: true
    sql: ${TABLE}.EME_JOB_ID

  - dimension: failure_count
    type: int
    sql: ${TABLE}.FAILURE_COUNT

  - dimension_group: last_activity
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.LAST_ACTIVITY

  - measure: count
    type: count
    drill_fields: [id, eme_job.id]

