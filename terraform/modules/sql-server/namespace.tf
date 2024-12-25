resource "kubernetes_namespace" "sql_server" {
  metadata {
    name = var.sql_server_namespace
  }
}