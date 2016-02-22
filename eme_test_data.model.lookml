- connection: eme-test-data

- include: "*.view.lookml"       # include all the views
- include: "*.dashboard.lookml"  # include all the dashboards



- explore: eme_queue_chunk
  joins:
    - join: eme_job
      type: left_outer 
      sql_on: ${eme_queue_chunk.eme_job_id} = ${eme_job.id}
      relationship: many_to_one

- explore: license_all
  joins:
    - join: users
      type: left_outer 
      sql_on: ${license_all.user_id} = ${users.id}
      relationship: many_to_one