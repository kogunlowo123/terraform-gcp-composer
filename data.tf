data "google_project" "current" {
  project_id = var.project_id
}

data "google_client_config" "current" {}

data "google_compute_network" "network" {
  count   = var.network != null ? 1 : 0
  project = var.project_id
  name    = element(split("/", var.network), length(split("/", var.network)) - 1)
}
