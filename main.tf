resource "google_composer_environment" "this" {
  provider = google-beta

  project = var.project_id
  name    = var.name
  region  = var.region
  labels  = local.merged_labels

  config {
    environment_size = var.environment_size
    resilience_mode  = var.resilience_mode

    software_config {
      image_version            = var.image_version
      airflow_config_overrides = var.airflow_config_overrides
      env_variables            = var.env_variables
      pypi_packages            = var.pypi_packages
      python_version           = var.python_version

      dynamic "cloud_data_lineage_integration" {
        for_each = var.cloud_data_lineage_integration_enabled ? [1] : []
        content {
          enabled = true
        }
      }
    }

    node_config {
      network         = var.network
      subnetwork      = var.subnetwork
      service_account = var.service_account
      tags            = var.tags

      dynamic "ip_allocation_policy" {
        for_each = local.has_ip_allocation ? [var.ip_allocation_policy] : []
        content {
          use_ip_aliases                = ip_allocation_policy.value.use_ip_aliases
          cluster_secondary_range_name  = ip_allocation_policy.value.cluster_secondary_range_name
          services_secondary_range_name = ip_allocation_policy.value.services_secondary_range_name
          cluster_ipv4_cidr_block       = ip_allocation_policy.value.cluster_ipv4_cidr_block
          services_ipv4_cidr_block      = ip_allocation_policy.value.services_ipv4_cidr_block
        }
      }
    }

    dynamic "private_environment_config" {
      for_each = local.has_private_config ? [var.private_environment_config] : []
      content {
        enable_private_endpoint                = private_environment_config.value.enable_private_endpoint
        master_ipv4_cidr_block                 = private_environment_config.value.master_ipv4_cidr_block
        cloud_sql_ipv4_cidr_block              = private_environment_config.value.cloud_sql_ipv4_cidr_block
        web_server_ipv4_cidr_block             = private_environment_config.value.web_server_ipv4_cidr_block
        cloud_composer_network_ipv4_cidr_block = private_environment_config.value.cloud_composer_network_ipv4_cidr_block
        connection_type                        = private_environment_config.value.connection_type
      }
    }

    dynamic "web_server_network_access_control" {
      for_each = length(var.web_server_allowed_ip_ranges) > 0 ? [1] : []
      content {
        dynamic "allowed_ip_range" {
          for_each = var.web_server_allowed_ip_ranges
          content {
            value       = allowed_ip_range.value.value
            description = allowed_ip_range.value.description
          }
        }
      }
    }

    dynamic "encryption_config" {
      for_each = var.kms_key_name != null ? [var.kms_key_name] : []
      content {
        kms_key_name = encryption_config.value
      }
    }

    dynamic "maintenance_window" {
      for_each = local.has_maintenance ? [var.maintenance_window] : []
      content {
        start_time = maintenance_window.value.start_time
        end_time   = maintenance_window.value.end_time
        recurrence = maintenance_window.value.recurrence
      }
    }

    dynamic "master_authorized_networks_config" {
      for_each = var.master_authorized_networks_config != null ? [var.master_authorized_networks_config] : []
      content {
        enabled = master_authorized_networks_config.value.enabled
        dynamic "cidr_blocks" {
          for_each = master_authorized_networks_config.value.cidr_blocks
          content {
            display_name = cidr_blocks.value.display_name
            cidr_block   = cidr_blocks.value.cidr_block
          }
        }
      }
    }

    dynamic "workloads_config" {
      for_each = local.has_workloads_config ? [1] : []
      content {
        dynamic "scheduler" {
          for_each = var.scheduler != null ? [var.scheduler] : []
          content {
            cpu        = scheduler.value.cpu
            memory_gb  = scheduler.value.memory_gb
            storage_gb = scheduler.value.storage_gb
            count      = scheduler.value.count
          }
        }

        dynamic "web_server" {
          for_each = var.web_server != null ? [var.web_server] : []
          content {
            cpu        = web_server.value.cpu
            memory_gb  = web_server.value.memory_gb
            storage_gb = web_server.value.storage_gb
          }
        }

        dynamic "worker" {
          for_each = var.worker != null ? [var.worker] : []
          content {
            cpu        = worker.value.cpu
            memory_gb  = worker.value.memory_gb
            storage_gb = worker.value.storage_gb
            min_count  = worker.value.min_count
            max_count  = worker.value.max_count
          }
        }

        dynamic "triggerer" {
          for_each = var.triggerer != null ? [var.triggerer] : []
          content {
            cpu       = triggerer.value.cpu
            memory_gb = triggerer.value.memory_gb
            count     = triggerer.value.count
          }
        }
      }
    }
  }

  lifecycle {
    prevent_destroy = false
  }

  timeouts {
    create = "60m"
    update = "60m"
    delete = "30m"
  }
}
