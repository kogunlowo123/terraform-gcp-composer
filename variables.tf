variable "project_id" {
  description = "The GCP project ID where the Composer environment will be created."
  type        = string

  validation {
    condition     = length(var.project_id) > 0
    error_message = "Project ID must not be empty."
  }
}

variable "region" {
  description = "The region where the Composer environment will be created."
  type        = string
  default     = "us-central1"
}

variable "name" {
  description = "The name of the Composer environment."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,62}$", var.name))
    error_message = "Name must start with a lowercase letter, contain only lowercase letters, numbers, and hyphens, and be at most 63 characters."
  }
}

variable "labels" {
  description = "Labels to apply to the Composer environment."
  type        = map(string)
  default     = {}
}

variable "composer_version" {
  description = "Major version of Cloud Composer. Use 2 for Composer 2 or 3 for Composer 3."
  type        = number
  default     = 2

  validation {
    condition     = contains([2, 3], var.composer_version)
    error_message = "Composer version must be 2 or 3."
  }
}

variable "image_version" {
  description = <<-EOT
    The version of the Composer image to use. Format: composer-MAJOR.MINOR.PATCH-airflow-MAJOR.MINOR.PATCH.
    Example: "composer-2.6.6-airflow-2.7.3"
  EOT
  type        = string
  default     = null
}

variable "airflow_config_overrides" {
  description = "Apache Airflow configuration overrides. Map of section-key => value."
  type        = map(string)
  default     = {}
}

variable "env_variables" {
  description = "Environment variables to set in the Airflow environment."
  type        = map(string)
  default     = {}
}

variable "pypi_packages" {
  description = "Map of custom PyPI packages to install. Key is package name, value is version spec (e.g., '==1.0.0', '>=2.0')."
  type        = map(string)
  default     = {}
}

variable "python_version" {
  description = "The Python version for the Composer environment. Only applicable for Composer 1."
  type        = string
  default     = null
}

variable "network" {
  description = "The self_link of the VPC network to use."
  type        = string
  default     = null
}

variable "subnetwork" {
  description = "The self_link of the subnetwork to use."
  type        = string
  default     = null
}

variable "service_account" {
  description = "The service account email for the Composer environment GKE nodes."
  type        = string
  default     = null
}

variable "tags" {
  description = "Network tags to apply to the GKE nodes."
  type        = list(string)
  default     = []
}

variable "enable_private_environment" {
  description = "If true, creates a private IP Composer environment."
  type        = bool
  default     = false
}

variable "private_environment_config" {
  description = <<-EOT
    Private environment configuration:
    - enable_private_endpoint: If true, the GKE master is not accessible from the public internet.
    - master_ipv4_cidr_block: CIDR block for the GKE master network (e.g., 172.16.0.0/28).
    - cloud_sql_ipv4_cidr_block: CIDR block for Cloud SQL (e.g., 10.0.0.0/12).
    - web_server_ipv4_cidr_block: CIDR block for the web server (e.g., 172.31.245.0/24).
    - cloud_composer_network_ipv4_cidr_block: CIDR for Composer tenant network.
    - connection_type: VPC_PEERING or PRIVATE_SERVICE_CONNECT.
  EOT
  type = object({
    enable_private_endpoint                = optional(bool, true)
    master_ipv4_cidr_block                 = optional(string)
    cloud_sql_ipv4_cidr_block              = optional(string)
    web_server_ipv4_cidr_block             = optional(string)
    cloud_composer_network_ipv4_cidr_block = optional(string)
    connection_type                        = optional(string)
  })
  default = null
}

variable "ip_allocation_policy" {
  description = <<-EOT
    IP allocation policy for GKE cluster:
    - use_ip_aliases: Whether to use IP aliases.
    - cluster_secondary_range_name: Name of the secondary range for pods.
    - services_secondary_range_name: Name of the secondary range for services.
    - cluster_ipv4_cidr_block: CIDR block for pods if not using named ranges.
    - services_ipv4_cidr_block: CIDR block for services if not using named ranges.
  EOT
  type = object({
    use_ip_aliases                = optional(bool, true)
    cluster_secondary_range_name  = optional(string)
    services_secondary_range_name = optional(string)
    cluster_ipv4_cidr_block       = optional(string)
    services_ipv4_cidr_block      = optional(string)
  })
  default = null
}

variable "maintenance_window" {
  description = <<-EOT
    Maintenance window configuration:
    - start_time: Start time in RFC 3339 format (e.g., "2024-01-01T00:00:00Z").
    - end_time: End time in RFC 3339 format.
    - recurrence: Recurrence in RFC 5545 RRULE format (e.g., "FREQ=WEEKLY;BYDAY=SA,SU").
  EOT
  type = object({
    start_time = string
    end_time   = string
    recurrence = string
  })
  default = null
}

variable "web_server_allowed_ip_ranges" {
  description = <<-EOT
    List of IP ranges allowed to access the Airflow web server. Each entry:
    - value: CIDR range (e.g., "0.0.0.0/0")
    - description: Description of the range
  EOT
  type = list(object({
    value       = string
    description = optional(string, "")
  }))
  default = []
}

variable "kms_key_name" {
  description = "The Cloud KMS key name for environment encryption."
  type        = string
  default     = null
}

variable "environment_size" {
  description = "The environment size. Supported values: ENVIRONMENT_SIZE_SMALL, ENVIRONMENT_SIZE_MEDIUM, ENVIRONMENT_SIZE_LARGE."
  type        = string
  default     = "ENVIRONMENT_SIZE_SMALL"

  validation {
    condition     = contains(["ENVIRONMENT_SIZE_SMALL", "ENVIRONMENT_SIZE_MEDIUM", "ENVIRONMENT_SIZE_LARGE"], var.environment_size)
    error_message = "Environment size must be ENVIRONMENT_SIZE_SMALL, ENVIRONMENT_SIZE_MEDIUM, or ENVIRONMENT_SIZE_LARGE."
  }
}

variable "resilience_mode" {
  description = "Resilience mode. HIGH_RESILIENCE enables multi-zone deployments."
  type        = string
  default     = null

  validation {
    condition     = var.resilience_mode == null || contains(["HIGH_RESILIENCE"], var.resilience_mode)
    error_message = "Resilience mode must be null or HIGH_RESILIENCE."
  }
}

variable "scheduler" {
  description = <<-EOT
    Scheduler workload configuration (Composer 2 only):
    - cpu: CPU in vCPUs (e.g., 0.5)
    - memory_gb: Memory in GB (e.g., 2)
    - storage_gb: Storage in GB (e.g., 1)
    - count: Number of scheduler instances (1-3)
  EOT
  type = object({
    cpu        = optional(number, 0.5)
    memory_gb  = optional(number, 2)
    storage_gb = optional(number, 1)
    count      = optional(number, 1)
  })
  default = null
}

variable "web_server" {
  description = <<-EOT
    Web server workload configuration (Composer 2 only):
    - cpu: CPU in vCPUs
    - memory_gb: Memory in GB
    - storage_gb: Storage in GB
  EOT
  type = object({
    cpu        = optional(number, 0.5)
    memory_gb  = optional(number, 2)
    storage_gb = optional(number, 1)
  })
  default = null
}

variable "worker" {
  description = <<-EOT
    Worker workload configuration (Composer 2 only):
    - cpu: CPU in vCPUs
    - memory_gb: Memory in GB
    - storage_gb: Storage in GB
    - min_count: Minimum number of workers
    - max_count: Maximum number of workers
  EOT
  type = object({
    cpu        = optional(number, 0.5)
    memory_gb  = optional(number, 2)
    storage_gb = optional(number, 1)
    min_count  = optional(number, 1)
    max_count  = optional(number, 3)
  })
  default = null
}

variable "triggerer" {
  description = <<-EOT
    Triggerer workload configuration (Composer 2 only):
    - cpu: CPU in vCPUs
    - memory_gb: Memory in GB
    - count: Number of triggerer instances
  EOT
  type = object({
    cpu       = optional(number, 0.5)
    memory_gb = optional(number, 0.5)
    count     = optional(number, 1)
  })
  default = null
}

variable "master_authorized_networks_config" {
  description = <<-EOT
    Master authorized networks configuration:
    - enabled: Whether to enable master authorized networks.
    - cidr_blocks: List of CIDR blocks with display_name and cidr_block.
  EOT
  type = object({
    enabled = optional(bool, false)
    cidr_blocks = optional(list(object({
      display_name = string
      cidr_block   = string
    })), [])
  })
  default = null
}

variable "cloud_data_lineage_integration_enabled" {
  description = "Whether Cloud Data Lineage integration is enabled."
  type        = bool
  default     = false
}
