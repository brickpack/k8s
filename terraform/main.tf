terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.14.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.14.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "http" {}

module "postgres" {
  source  = "./modules/postgres"
  pg_user = var.pg_user
  pg_pass = var.pg_pass
  pg_db   = var.pg_db
}

module "airflow" {
  source                = "./modules/airflow"
  kube_config_path      = var.kube_config_path
  git_repo              = var.git_repo
  git_branch            = var.git_branch
  postgres_username     = var.postgres_username
  postgres_password     = var.postgres_password
  webserver_password    = var.webserver_password
  fernet_key            = var.fernet_key
  webserver_secret_key  = var.webserver_secret_key
  namespace             = var.namespace
  airflow_version       = var.airflow_version
  airflow_chart_version = var.airflow_chart_version
  airflow_release_name  = var.airflow_release_name
  airflow_api_url       = var.airflow_api_url
  airflow_username      = var.airflow_username
  airflow_password      = var.airflow_password
  pg_db                 = var.pg_db
  pg_pass               = var.pg_pass
  pg_user               = var.pg_user
  pg_host               = var.pg_host
  connections           = var.connections
}

module "monitoring" {
  source                 = "./modules/monitoring"
  monitoring_namespace   = var.monitoring_namespace
  grafana_admin_password = var.grafana_admin_password
  smtp_password          = var.smtp_password
}

module "sql_server" {
  source = "./modules/sql-server"

  sql_server_namespace        = var.sql_server_namespace
  sql_helm_release_name       = var.sql_helm_release_name
  sql_server_sa_password      = var.sql_server_sa_password
  sql_server_accept_eula      = var.sql_server_accept_eula
  sql_server_persistence_size = var.sql_server_persistence_size
}

# module "github_actions_runner" {
#   source              = "./modules/github-actions-runner"
#   github_namespace    = var.github_namespace
#   github_pat          = var.github_pat
#   github_owner        = var.github_owner
#   github_repo         = var.github_repo
#   runner_replicas     = 2
# }

# module "dbt" {
#   source        = "./modules/dbt"
#   dbt_namespace = var.dbt_namespace
#   dbt_type      = var.dbt_type
#   dbt_location  = var.dbt_location
#   dbt_user      = var.dbt_user
#   dbt_password  = var.dbt_password
# }