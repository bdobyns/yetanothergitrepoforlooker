- view: content_item
  fields:

  - dimension: area
    type: string
    sql: ${TABLE}.area

  - dimension: article_type_id
    type: string
    sql: ${TABLE}.articleTypeId

  - dimension: doi
    type: string
    sql: ${TABLE}.doi

  - dimension: iid
    type: string
    sql: ${TABLE}.iid

  - dimension: issue
    type: string
    sql: ${TABLE}.issue

  - dimension: journal_code
    type: string
    sql: ${TABLE}.journalCode

  - dimension_group: lastmodified
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.lastmodified

  - dimension: lvdoi
    type: string
    sql: ${TABLE}.lvdoi

  - dimension: parent_id
    type: int
    sql: ${TABLE}.parentId

  - dimension: pubid
    type: int
    sql: ${TABLE}.pubid

  - dimension_group: publication
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.publicationDate

  - dimension: type
    type: string
    sql: ${TABLE}.type

  - dimension: volume
    type: string
    sql: ${TABLE}.volume

  - measure: count
    type: count
    drill_fields: []

