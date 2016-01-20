- view: entitlement_all
  fields:

  - dimension: id
    primary_key: true
    type: int
    sql: ${TABLE}.id

  - dimension: code
    type: string
    sql: ${TABLE}.code

  - dimension: has_area_constraints
    type: int
    sql: ${TABLE}.hasAreaConstraints

  - dimension: has_article_type_constraints
    type: int
    sql: ${TABLE}.hasArticleTypeConstraints

  - dimension: has_display_format_constraints
    type: int
    sql: ${TABLE}.hasDisplayFormatConstraints

  - dimension: has_issue_type_constraints
    type: int
    sql: ${TABLE}.hasIssueTypeConstraints

  - dimension: has_moving_wall_constraints
    type: int
    sql: ${TABLE}.hasMovingWallConstraints

  - dimension: has_volume_issue_constraints
    type: int
    sql: ${TABLE}.hasVolumeIssueConstraints

  - dimension: has_wall_date_constraints
    type: int
    sql: ${TABLE}.hasWallDateConstraints

  - dimension: managed_by
    type: string
    sql: ${TABLE}.managedBy

  - dimension: name
    type: string
    sql: ${TABLE}.name

  - dimension: pub_id
    type: int
    sql: ${TABLE}.pubId

  - measure: count
    type: count
    drill_fields: [id, name]

