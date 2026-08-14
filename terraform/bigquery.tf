resource "google_bigquery_dataset" "bronze" {
  dataset_id = "bronze"
  location   = "US"
}

resource "google_bigquery_dataset" "silver" {
  dataset_id = "silver"
  location   = "US"
}

resource "google_bigquery_dataset" "gold" {
  dataset_id = "gold"
  location   = "US"
}

resource "google_service_account" "dbt_runner" {
  account_id   = "dbt-service-account"   
  display_name = "dbt-service-account"
  description  = "Used by dbt to read/write BigQuery datasets for the medallion warehouse project"
}

resource "google_project_iam_member" "dbt_data_editor" {
  project = "data-warehouse-dbt"
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.dbt_runner.email}"
}

resource "google_project_iam_member" "dbt_job_user" {
  project = "data-warehouse-dbt"
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.dbt_runner.email}"
}