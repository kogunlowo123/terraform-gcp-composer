locals {
  default_labels = {
    managed-by = "terraform"
  }

  merged_labels = merge(local.default_labels, var.labels)

  is_composer_2 = var.composer_version == 2
  is_composer_3 = var.composer_version == 3

  # Determine if workloads config should be set
  has_workloads_config = (
    var.scheduler != null ||
    var.web_server != null ||
    var.worker != null ||
    var.triggerer != null
  )

  # Environment config flags
  has_private_config = var.enable_private_environment && var.private_environment_config != null
  has_ip_allocation  = var.ip_allocation_policy != null
  has_maintenance    = var.maintenance_window != null
}
