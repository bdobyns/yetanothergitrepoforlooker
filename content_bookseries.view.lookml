- view: content_bookseries
  fields:

  - dimension: area
    type: string
    sql: ${TABLE}.area

  - dimension: doi
    type: string
    sql: ${TABLE}.doi

  - dimension_group: lastmodified
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.lastmodified

  - dimension: pubid
    type: int
    sql: ${TABLE}.pubid

  - dimension: upubid
    type: int
    sql: ${TABLE}.upubid

  - measure: count
    type: count
    drill_fields: []

