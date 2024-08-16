output "airflow_namespace" {
  value       = kubernetes_namespace.airflow.metadata[0].name
  description = "Namespace where Airflow is deployed"
}

output "airflow_web_service" {
  value       = "${helm_release.airflow.name}-webserver"
  description = "Airflow web service name"
}
