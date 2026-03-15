module "test" {
  source = "../"

  project_id       = "test-project-id"
  region           = "us-central1"
  name             = "test-composer-env"
  composer_version = 2
  environment_size = "ENVIRONMENT_SIZE_SMALL"

  labels = {
    environment = "test"
    managed_by  = "terraform"
  }

  airflow_config_overrides = {
    "core-dags_are_paused_at_creation" = "True"
    "webserver-dag_default_view"       = "graph"
  }

  env_variables = {
    ENV       = "test"
    LOG_LEVEL = "INFO"
  }

  pypi_packages = {
    apache-airflow-providers-slack = ">=8.0.0"
    pandas                         = ">=2.0.0"
  }

  scheduler = {
    cpu        = 0.5
    memory_gb  = 2
    storage_gb = 1
    count      = 1
  }

  web_server = {
    cpu        = 0.5
    memory_gb  = 2
    storage_gb = 1
  }

  worker = {
    cpu        = 1
    memory_gb  = 4
    storage_gb = 2
    min_count  = 1
    max_count  = 3
  }

  triggerer = {
    cpu       = 0.5
    memory_gb = 0.5
    count     = 1
  }
}
