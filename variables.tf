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
  description = "Major version of Cloud Composer (2 or 3)."
  type        = number
  default     = 2

  validation {
    condition     = contains([2, 3], var.composer_version)
    error_message = "Composer version must be 2 or 3."
  }
}

variable "image_version" {
  description = "The Composer image version (e.g., composer-2.6.6-airflow-2.7.3)."
  type        = string
  default     = null
}

variable "airflow_config_overrides" {
  description = "Apache Airflow configuration overrides as a map of section-key to value."
  type        = map(string)
  default     = {}
}

variable "env_variables" {
  description = "Environment variables to set in the Airflow environment."
  type        = map(string)
  default     = {}
}

variable "pypi_packages" {
  description = "Map of custom PyPI packages to install, key is package name and value is version spec."
  type        = map(string)
  default     = {}
}

variable "python_version" {
  description = "The Python version for the Composer environment (Composer 1 only)."
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
  description = "Private environment configuration for endpoint, CIDR blocks, and connection type."
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
  description = "IP allocation policy for GKE cluster with IP aliases and secondary ranges."
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
  description = "Maintenance window with start_time, end_time (RFC 3339), and recurrence (RFC 5545)."
  type = object({
    start_time = string
    end_time   = string
    recurrence = string
  })
  default = null
}

variable "web_server_allowed_ip_ranges" {
  description = "List of IP ranges allowed to access the Airflow web server."
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
  description = "The environment size (ENVIRONMENT_SIZE_SMALL, ENVIRONMENT_SIZE_MEDIUM, ENVIRONMENT_SIZE_LARGE)."
  type        = string
  default     = "ENVIRONMENT_SIZE_SMALL"

  validation {
    condition     = contains(["ENVIRONMENT_SIZE_SMALL", "ENVIRONMENT_SIZE_MEDIUM", "ENVIRONMENT_SIZE_LARGE"], var.environment_size)
    error_message = "Environment size must be ENVIRONMENT_SIZE_SMALL, ENVIRONMENT_SIZE_MEDIUM, or ENVIRONMENT_SIZE_LARGE."
  }
}

variable "resilience_mode" {
  description = "Resilience mode, set to HIGH_RESILIENCE for multi-zone deployments."
  type        = string
  default     = null

  validation {
    condition     = var.resilience_mode == null || contains(["HIGH_RESILIENCE"], var.resilience_mode)
    error_message = "Resilience mode must be null or HIGH_RESILIENCE."
  }
}

variable "scheduler" {
  description = "Scheduler workload configuration with cpu, memory_gb, storage_gb, and count."
  type = object({
    cpu        = optional(number, 0.5)
    memory_gb  = optional(number, 2)
    storage_gb = optional(number, 1)
    count      = optional(number, 1)
  })
  default = null
}

variable "web_server" {
  description = "Web server workload configuration with cpu, memory_gb, and storage_gb."
  type = object({
    cpu        = optional(number, 0.5)
    memory_gb  = optional(number, 2)
    storage_gb = optional(number, 1)
  })
  default = null
}

variable "worker" {
  description = "Worker workload configuration with cpu, memory_gb, storage_gb, min_count, and max_count."
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
  description = "Triggerer workload configuration with cpu, memory_gb, and count."
  type = object({
    cpu       = optional(number, 0.5)
    memory_gb = optional(number, 0.5)
    count     = optional(number, 1)
  })
  default = null
}

variable "master_authorized_networks_config" {
  description = "Master authorized networks configuration with enabled flag and CIDR blocks."
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
