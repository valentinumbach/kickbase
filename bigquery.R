Sys.setenv('GCE_AUTH_FILE' = '~/git/kickbase/google-oauth.json')
library(googleComputeEngineR)
library(bigQueryR)

set_bigquery_environment <- function(env_name) {
  bqr_projects <- bqr_list_projects()
  if (env_name %in% bqr_projects$friendlyName) {
    project_id <- bqr_projects$id[which(bqr_projects$friendlyName == env_name)]
  } else {
    print(paste0('Create Google Cloud project \'', env_name, '\''))
    return()
  }
  bqr_datasets <- bqr_list_datasets(project_id)
  if (env_name %in% bqr_datasets$datasetId) {
    dataset_id <- env_name
  } else {
    paste0('Create BigQuery dataset \'', env_name, '\'')
    return()
  }
  list(project_id = project_id, dataset_id = dataset_id)
}

write_bigquery_table <- function(project_id, dataset_id, table_id, df) {
  bqr_tables <- bqr_list_tables(project_id, dataset_id)
  if (table_id %in% bqr_tables$tableId) {
    bqr_upload_data(project_id, dataset_id, table_id, df, overwrite = T)
  } else {
    bqr_create_table(project_id, dataset_id, table_id, df)
    bqr_upload_data(project_id, dataset_id, table_id, df, overwrite = T)
  }
}
