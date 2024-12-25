variable "sql_server_namespace" {
  description = "Namespace to deploy SQL Server into."
  type        = string
  default     = "sql-server"
}

variable "sql_helm_release_name" {
  description = "Release name for the Helm release."
  type        = string
  default     = "sql-server"
}

variable "sql_server_sa_password" {
  description = "SA password for SQL Server."
  type        = string
}

variable "sql_server_accept_eula" {
  description = "Accept the SQL Server EULA."
  type        = string
  default     = "Y"
}

variable "sql_server_persistence_size" {
  description = "Persistent storage size for SQL Server."
  type        = string
  default     = "8Gi"
}