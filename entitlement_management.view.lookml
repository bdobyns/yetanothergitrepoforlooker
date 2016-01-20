- view: entitlement_management
  fields:

  - dimension: id
    primary_key: true
    type: int
    sql: ${TABLE}.ID

  - dimension: action
    type: string
    sql: ${TABLE}.ACTION

  - dimension: entitlement_id
    type: int
    sql: ${TABLE}.ENTITLEMENT_ID

  - dimension: entitlement_managed
    type: string
    sql: ${TABLE}.ENTITLEMENT_MANAGED

  - dimension: job_id
    type: int
    sql: ${TABLE}.JOB_ID

  - dimension: job_source
    type: string
    sql: ${TABLE}.JOB_SOURCE

  - dimension: new_value
    type: string
    sql: ${TABLE}.NEW_VALUE

  - dimension: old_value
    type: string
    sql: ${TABLE}.OLD_VALUE

  - dimension_group: timestamp
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.TIMESTAMP

  - dimension: type
    type: string
    sql: ${TABLE}.TYPE

  - dimension: written
    type: int
    sql: ${TABLE}.WRITTEN

  - measure: count
    type: count
    drill_fields: [id]

