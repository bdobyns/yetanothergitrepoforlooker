- view: users
  fields:

  - dimension: id
    primary_key: true
    type: int
    sql: ${TABLE}.id

  - dimension: blocked
    type: int
    sql: ${TABLE}.blocked

  - dimension: description
    type: string
    sql: ${TABLE}.description

  - dimension: group_identity_id
    type: int
    sql: ${TABLE}.groupIdentityId

  - dimension: max_ip
    type: string
    sql: ${TABLE}.maxIp

  - dimension: min_ip
    type: string
    sql: ${TABLE}.minIp

  - dimension: uuid
    type: string
    sql: ${TABLE}.uuid

  - dimension: xsitype
    type: string
    sql: ${TABLE}.xsitype

  - measure: count
    type: count
    drill_fields: [id, license_all.count]

