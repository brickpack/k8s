# Postgres
variable "pg_user" {
  type = string

}

variable "pg_pass" {
  type = string

}

variable "pg_db" {
  type = string

}

# Airflow
variable "kube_config_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "namespace" {
  description = "Kubernetes namespace for Airflow"
  type        = string
}

variable "monitoring_namespace" {
  description = "Kubernetes namespace for Monitoring Stack"
  type        = string
}

variable "airflow_version" {
  description = "Airflow version to deploy"
  type        = string
}

variable "airflow_chart_version" {
  description = "The version of the Airflow Helm chart to use"
  type        = string
}

variable "airflow_release_name" {
  description = "Name of the Airflow Helm release"
  type        = string
}

variable "fernet_key" {
  description = "Fernet key for Airflow"
  type        = string
  sensitive   = true
}

variable "git_repo" {
  description = "Git repository URL for DAGs"
  type        = string
}

variable "git_branch" {
  description = "Git branch to sync"
  type        = string
  default     = "main"
}

variable "postgres_username" {
  description = "Username for PostgreSQL"
  type        = string
  sensitive   = true
}

variable "postgres_password" {
  description = "Password for PostgreSQL"
  type        = string
  sensitive   = true
}

variable "webserver_password" {
  description = "Password for Airflow Weserver"
  type        = string
  sensitive   = true
}

variable "create_storage_class" {
  description = "Whether to create the standard StorageClass"
  type        = bool
  default     = false
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana"
  type        = string
}