- view: content_category
  fields:

  - dimension_group: lastmodified
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.lastmodified

  - dimension: pubid
    type: int
    sql: ${TABLE}.pubid

  - dimension: publication_state
    type: string
    sql: ${TABLE}.publicationState

  - measure: count
    type: count
    drill_fields: []

