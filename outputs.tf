output "environment_id" {
  description = "The ID of the Composer environment."
  value       = google_composer_environment.this.id
}

output "environment_name" {
  description = "The name of the Composer environment."
  value       = google_composer_environment.this.name
}

output "gke_cluster" {
  description = "The GKE cluster associated with the Composer environment."
  value       = google_composer_environment.this.config[0].gke_cluster
}

output "dag_gcs_prefix" {
  description = "The Cloud Storage prefix of the DAGs folder."
  value       = google_composer_environment.this.config[0].dag_gcs_prefix
}

output "airflow_uri" {
  description = "The URI of the Airflow web UI."
  value       = google_composer_environment.this.config[0].airflow_uri
}

output "airflow_database_config" {
  description = "The Airflow database configuration."
  value       = google_composer_environment.this.config[0].database_config
}

output "environment_config" {
  description = "The full environment configuration."
  value       = google_composer_environment.this.config
  sensitive   = true
}

output "effective_labels" {
  description = "The effective labels on the environment."
  value       = google_composer_environment.this.effective_labels
}
