terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
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

module "postgres" {
  source  = "./modules/postgres"
  pg_user = var.pg_user
  pg_pass = var.pg_pass
  pg_db   = var.pg_db
}

module "airflow" {
  source                 = "./modules/airflow"
  kube_config_path       = var.kube_config_path
  git_repo               = var.git_repo
  git_branch             = var.git_branch
  postgres_username      = var.postgres_username
  postgres_password      = var.postgres_password
  webserver_password     = var.webserver_password
  fernet_key             = var.fernet_key
  webserver_secret_key   = var.webserver_secret_key
  namespace              = var.namespace
  airflow_version        = var.airflow_version
  airflow_chart_version  = var.airflow_chart_version
  airflow_release_name   = var.airflow_release_name
}

module "monitoring" {
  source = "./modules/monitoring"
  monitoring_namespace   = var.monitoring_namespace
  grafana_admin_password = var.grafana_admin_password
}