variable "kube_config_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "namespace" {
  description = "Kubernetes namespace for Airflow"
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

variable "airflow_api_url" {
  description = "Base URL for Airflow API"
  type        = string
}

variable "airflow_username" {
  description = "Airflow API username"
  type        = string
  sensitive   = true
}

variable "airflow_password" {
  description = "Airflow API password"
  type        = string
  sensitive   = true
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

variable "webserver_secret_key" {
  description = "Static secret key for the Airflow webserver"
  type        = string
}

variable "pg_user" {
  type = string
  sensitive   = true
}

variable "pg_pass" {
  type = string
  sensitive   = true
}

variable "pg_db" {
  type = string
  sensitive   = true
}

variable "pg_host" {
  type = string
  sensitive = true  
}

variable "conn_type" {
  type = string  
}

variable "conn_id" {
  type = string  
}