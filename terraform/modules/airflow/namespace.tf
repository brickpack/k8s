resource "kubernetes_namespace" "airflow" {
  metadata {
    name = var.namespace
  }
}
