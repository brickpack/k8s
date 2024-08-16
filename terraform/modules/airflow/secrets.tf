resource "kubernetes_secret" "airflow_secrets" {
  metadata {
    name      = "airflow-secrets"
    namespace = kubernetes_namespace.airflow.metadata[0].name
  }

  data = {
    "postgres-password" = var.postgres_password
    "fernet-key"        = var.fernet_key
  }

  type = "Opaque"
}
