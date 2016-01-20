- view: content_chapter
  fields:

  - dimension: area
    type: string
    sql: ${TABLE}.area

  - dimension: book_id
    type: int
    sql: ${TABLE}.bookId

  - dimension: chapter_id
    type: int
    sql: ${TABLE}.chapterId

  - dimension: doi
    type: string
    sql: ${TABLE}.doi

  - dimension: pubid
    type: int
    sql: ${TABLE}.pubid

  - dimension: toc_order
    type: number
    sql: ${TABLE}.tocOrder

  - measure: count
    type: count
    drill_fields: []

