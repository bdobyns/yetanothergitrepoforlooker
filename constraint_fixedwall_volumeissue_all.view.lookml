- view: constraint_fixedwall_volumeissue_all
  fields:

  - dimension: entitlement_id
    type: int
    sql: ${TABLE}.entitlementId

  - dimension: is_front
    type: string
    sql: ${TABLE}.isFront

  - dimension: volume_issue_issue
    type: string
    sql: ${TABLE}.volumeIssue_issue

  - dimension: volume_issue_volume
    type: string
    sql: ${TABLE}.volumeIssue_volume

  - measure: count
    type: count
    drill_fields: []

