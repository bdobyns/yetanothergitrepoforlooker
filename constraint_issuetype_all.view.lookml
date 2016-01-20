- view: constraint_issuetype_all
  fields:

  - dimension: entitlement_id
    type: int
    sql: ${TABLE}.entitlementId

  - dimension: issue_type
    type: string
    sql: ${TABLE}.issueType

  - measure: count
    type: count
    drill_fields: []

