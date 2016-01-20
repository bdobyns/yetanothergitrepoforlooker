- view: content_book
  fields:

  - dimension: area
    type: string
    sql: ${TABLE}.area

  - dimension: book_order
    type: number
    sql: ${TABLE}.bookOrder

  - dimension: book_parent_id
    type: int
    sql: ${TABLE}.bookParentId

  - dimension: book_type
    type: string
    sql: ${TABLE}.bookType

  - dimension: doi
    type: string
    sql: ${TABLE}.doi

  - dimension: pubid
    type: int
    sql: ${TABLE}.pubid

  - dimension_group: publication
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.publicationDate

  - dimension: publication_date_string
    type: string
    sql: ${TABLE}.publicationDateString

  - dimension: publisher_name
    type: string
    sql: ${TABLE}.publisherName

  - measure: count
    type: count
    drill_fields: [publisher_name]

