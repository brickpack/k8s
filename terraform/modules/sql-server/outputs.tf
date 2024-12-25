output "sql_server_namespace" {
  description = "The namespace where SQL Server is deployed."
  value       = kubernetes_namespace.sql_server.metadata[0].name
}

output "sql_server_service" {
  description = "Details of the SQL Server service."
  value       = helm_release.sql_server
}