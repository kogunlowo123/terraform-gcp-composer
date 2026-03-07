provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "region" {
  description = "The GCP region."
  type        = string
  default     = "us-central1"
}

module "composer" {
  source = "../../"

  project_id = var.project_id
  region     = var.region
  name       = "basic-airflow-env"

  environment_size = "ENVIRONMENT_SIZE_SMALL"

  labels = {
    environment = "dev"
    team        = "data-engineering"
  }
}

output "environment_name" {
  description = "The Composer environment name."
  value       = module.composer.environment_name
}

output "airflow_uri" {
  description = "The Airflow web UI URI."
  value       = module.composer.airflow_uri
}

output "dag_gcs_prefix" {
  description = "The DAGs GCS folder prefix."
  value       = module.composer.dag_gcs_prefix
}
