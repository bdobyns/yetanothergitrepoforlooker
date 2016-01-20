- view: pss_price
  fields:

  - dimension: detail_entitlement_id
    type: string
    sql: ${TABLE}.detailEntitlementId

  - dimension: entitlement_id
    type: string
    sql: ${TABLE}.entitlementId

  - dimension: jstor_article_fee
    type: number
    sql: ${TABLE}.jstorArticleFee

  - dimension: jstor_issue_fee
    type: number
    sql: ${TABLE}.jstorIssueFee

  - dimension_group: meta_timestamp
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.meta_timestamp

  - dimension: publisher_article_price
    type: number
    sql: ${TABLE}.publisherArticlePrice

  - dimension: publisher_issue_price
    type: number
    sql: ${TABLE}.publisherIssuePrice

  - measure: count
    type: count
    drill_fields: []

