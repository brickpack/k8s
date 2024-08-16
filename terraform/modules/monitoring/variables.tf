
variable "monitoring_namespace" {
  description = "Kubernetes namespace for Monitoring Stack"
  type        = string
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana"
  type        = string
}
