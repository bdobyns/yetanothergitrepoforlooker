- view: rels
  fields:

  - dimension: relation_id
    type: string
    sql: ${TABLE}.relationId

  - dimension: user1_id
    type: int
    sql: ${TABLE}.user1Id

  - dimension: user2_id
    type: int
    sql: ${TABLE}.user2Id

  - measure: count
    type: count
    drill_fields: []

