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

variable "kms_key_name" {
  description = "Cloud KMS key for environment encryption."
  type        = string
  default     = null
}

module "composer" {
  source = "../../"

  project_id       = var.project_id
  region           = var.region
  name             = "production-airflow-env"
  environment_size = "ENVIRONMENT_SIZE_LARGE"
  resilience_mode  = "HIGH_RESILIENCE"

  image_version = "composer-2.6.6-airflow-2.7.3"

  network         = var.network
  subnetwork      = var.subnetwork
  service_account = var.service_account
  tags            = ["composer", "airflow", "production"]
  kms_key_name    = var.kms_key_name

  # Full private environment
  enable_private_environment = true
  private_environment_config = {
    enable_private_endpoint                = true
    master_ipv4_cidr_block                 = "172.16.0.0/28"
    cloud_sql_ipv4_cidr_block              = "10.0.0.0/12"
    web_server_ipv4_cidr_block             = "172.31.245.0/24"
    cloud_composer_network_ipv4_cidr_block = "172.31.244.0/24"
    connection_type                        = "VPC_PEERING"
  }

  ip_allocation_policy = {
    use_ip_aliases           = true
    cluster_ipv4_cidr_block  = "10.4.0.0/14"
    services_ipv4_cidr_block = "10.8.0.0/20"
  }

  master_authorized_networks_config = {
    enabled = true
    cidr_blocks = [
      {
        display_name = "Office network"
        cidr_block   = "203.0.113.0/24"
      },
      {
        display_name = "VPN network"
        cidr_block   = "198.51.100.0/24"
      },
      {
        display_name = "CI/CD runners"
        cidr_block   = "192.0.2.0/24"
      }
    ]
  }

  # Comprehensive Airflow configuration
  airflow_config_overrides = {
    "core-dags_are_paused_at_creation"    = "True"
    "core-max_active_runs_per_dag"        = "5"
    "core-parallelism"                    = "32"
    "core-dag_concurrency"                = "16"
    "celery-worker_concurrency"           = "16"
    "webserver-dag_default_view"          = "graph"
    "webserver-expose_config"             = "False"
    "scheduler-dag_dir_list_interval"     = "30"
    "scheduler-min_file_process_interval" = "60"
    "scheduler-parsing_processes"         = "4"
    "email-email_backend"                 = "airflow.providers.google.cloud.utils.credentials_provider"
  }

  env_variables = {
    ENV                   = "production"
    GCP_PROJECT           = var.project_id
    GCP_REGION            = var.region
    DATA_BUCKET           = "${var.project_id}-data"
    STAGING_BUCKET        = "${var.project_id}-staging"
    ARCHIVE_BUCKET        = "${var.project_id}-archive"
    BIGQUERY_DATASET      = "analytics"
    SLACK_WEBHOOK_URL     = "https://hooks.slack.com/services/xxx"
    PAGERDUTY_SERVICE_KEY = "xxx"
    LOG_LEVEL             = "INFO"
  }

  pypi_packages = {
    "apache-airflow-providers-slack"    = ">=7.0.0"
    "apache-airflow-providers-google"   = ">=10.0.0"
    "apache-airflow-providers-http"     = ">=4.0.0"
    "apache-airflow-providers-ssh"      = ">=3.0.0"
    "apache-airflow-providers-postgres" = ">=5.0.0"
    "pandas"                            = ">=2.0.0"
    "numpy"                             = ">=1.24.0"
    "google-cloud-bigquery"             = ">=3.0.0"
    "google-cloud-storage"              = ">=2.0.0"
    "google-cloud-pubsub"               = ">=2.0.0"
    "pydantic"                          = ">=2.0.0"
    "requests"                          = ">=2.31.0"
    "sentry-sdk"                        = ">=1.0.0"
  }

  # Production-grade workloads config
  scheduler = {
    cpu        = 2
    memory_gb  = 8
    storage_gb = 4
    count      = 2
  }

  web_server = {
    cpu        = 2
    memory_gb  = 8
    storage_gb = 4
  }

  worker = {
    cpu        = 4
    memory_gb  = 16
    storage_gb = 8
    min_count  = 3
    max_count  = 12
  }

  triggerer = {
    cpu       = 1
    memory_gb = 2
    count     = 2
  }

  # Maintenance during low-traffic periods
  maintenance_window = {
    start_time = "2024-01-01T02:00:00Z"
    end_time   = "2024-01-01T06:00:00Z"
    recurrence = "FREQ=WEEKLY;BYDAY=SU"
  }

  # Web server access control
  web_server_allowed_ip_ranges = [
    {
      value       = "203.0.113.0/24"
      description = "Corporate office network"
    },
    {
      value       = "198.51.100.0/24"
      description = "VPN gateway"
    },
    {
      value       = "192.0.2.0/24"
      description = "CI/CD infrastructure"
    }
  ]

  cloud_data_lineage_integration_enabled = true

  labels = {
    environment = "production"
    team        = "data-platform"
    cost-center = "data-engineering"
    compliance  = "soc2"
    criticality = "high"
  }
}

output "environment_id" {
  description = "The Composer environment ID."
  value       = module.composer.environment_id
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
  description = "The GKE cluster name."
  value       = module.composer.gke_cluster
}
