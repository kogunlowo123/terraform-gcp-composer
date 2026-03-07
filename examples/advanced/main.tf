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

variable "network" {
  description = "VPC network self_link."
  type        = string
}

variable "subnetwork" {
  description = "Subnet self_link."
  type        = string
}

variable "service_account" {
  description = "Service account email for Composer."
  type        = string
}

module "composer" {
  source = "../../"

  project_id       = var.project_id
  region           = var.region
  name             = "advanced-airflow-env"
  environment_size = "ENVIRONMENT_SIZE_MEDIUM"

  image_version = "composer-2.6.6-airflow-2.7.3"

  network         = var.network
  subnetwork      = var.subnetwork
  service_account = var.service_account

  enable_private_environment = true
  private_environment_config = {
    enable_private_endpoint   = false
    master_ipv4_cidr_block    = "172.16.0.0/28"
    cloud_sql_ipv4_cidr_block = "10.0.0.0/12"
  }

  ip_allocation_policy = {
    use_ip_aliases          = true
    cluster_ipv4_cidr_block  = "10.4.0.0/14"
    services_ipv4_cidr_block = "10.8.0.0/20"
  }

  airflow_config_overrides = {
    "core-dags_are_paused_at_creation" = "True"
    "core-max_active_runs_per_dag"     = "3"
    "celery-worker_concurrency"        = "8"
    "webserver-dag_default_view"       = "graph"
    "scheduler-dag_dir_list_interval"  = "60"
  }

  env_variables = {
    ENV             = "staging"
    GCP_PROJECT     = var.project_id
    SLACK_WEBHOOK   = "https://hooks.slack.com/services/xxx"
    DATA_BUCKET     = "${var.project_id}-data"
  }

  pypi_packages = {
    "apache-airflow-providers-slack"         = ">=7.0.0"
    "apache-airflow-providers-google"        = ">=10.0.0"
    "apache-airflow-providers-http"          = ">=4.0.0"
    "pandas"                                  = ">=2.0.0"
    "google-cloud-bigquery"                  = ">=3.0.0"
  }

  scheduler = {
    cpu        = 1
    memory_gb  = 4
    storage_gb = 2
    count      = 2
  }

  web_server = {
    cpu        = 1
    memory_gb  = 4
    storage_gb = 2
  }

  worker = {
    cpu        = 2
    memory_gb  = 8
    storage_gb = 4
    min_count  = 2
    max_count  = 6
  }

  triggerer = {
    cpu       = 0.5
    memory_gb = 1
    count     = 1
  }

  maintenance_window = {
    start_time = "2024-01-01T02:00:00Z"
    end_time   = "2024-01-01T06:00:00Z"
    recurrence = "FREQ=WEEKLY;BYDAY=SA"
  }

  web_server_allowed_ip_ranges = [
    {
      value       = "203.0.113.0/24"
      description = "Office network"
    },
    {
      value       = "198.51.100.0/24"
      description = "VPN network"
    }
  ]

  labels = {
    environment = "staging"
    team        = "data-engineering"
    cost-center = "data-platform"
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

output "gke_cluster" {
  description = "The GKE cluster."
  value       = module.composer.gke_cluster
}
