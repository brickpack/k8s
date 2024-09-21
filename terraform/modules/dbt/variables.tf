variable "dbt_namespace" {
  description = "Kubernetes namespace for dbt"
  type        = string
}

variable "dbt_type" {
  description = "Kubernetes namespace for dbt"
  type        = string
}
variable "dbt_location" {
  description = "Kubernetes namespace for dbt"
  type        = string
}
variable "dbt_user" {
  description = "Kubernetes namespace for dbt"
  type        = string
}
variable "dbt_password" {
  description = "Kubernetes namespace for dbt"
  type        = string
  sensitive   = true
}
