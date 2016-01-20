- connection: eme-test-data

- include: "*.view.lookml"       # include all the views
- include: "*.dashboard.lookml"  # include all the dashboards

- explore: book_meta

- explore: combo_entitlement_all

- explore: constraint_area_all

- explore: constraint_articletype_all

- explore: constraint_displayformat_all

- explore: constraint_fixedwall_volumeissue_all

- explore: constraint_fixedwall_walldate_all

- explore: constraint_issuetype_all

- explore: constraint_movingwall_all

- explore: content_all

- explore: content_book

- explore: content_bookseries

- explore: content_category

- explore: content_chapter

- explore: content_item

- explore: csp_meta

- explore: distinguished_entitlements

- explore: eme_job

- explore: eme_job_backup

- explore: eme_job_metadata

- explore: eme_queue_chunk
  joins:
    - join: eme_job
      type: left_outer 
      sql_on: ${eme_queue_chunk.eme_job_id} = ${eme_job.id}
      relationship: many_to_one


- explore: eme_queue_chunk_meta

- explore: entitlement_all

- explore: entitlement_management

- explore: iap_meta

- explore: important_collections

- explore: jpass_meta

- explore: license_all
  joins:
    - join: users
      type: left_outer 
      sql_on: ${license_all.user_id} = ${users.id}
      relationship: many_to_one


- explore: product_all

- explore: pss_price

- explore: rels

- explore: skippable_entitlements

- explore: temp_plants

- explore: users

