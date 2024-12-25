resource "kubernetes_secret" "airflow_secrets" {
  metadata {
    name      = "airflow-secrets"
    namespace = kubernetes_namespace.airflow.metadata[0].name
  }

  data = {
    "postgres-password" = base64encode(var.postgres_password)
    "fernet-key"        = base64encode(var.fernet_key)
  }

  type = "Opaque"
}

resource "kubernetes_secret" "airflow_webserver_secret" {
  metadata {
    name      = "airflow-webserver-secret"
    namespace = kubernetes_namespace.airflow.metadata[0].name
  }

  data = {
    "webserver-secret-key" = base64encode(var.webserver_secret_key)
  }

  type = "Opaque"
}

resource "kubernetes_secret" "airflow_connections" {
  metadata {
    name      = "airflow-connections"
    namespace = kubernetes_namespace.airflow.metadata[0].name
  }

  data = {
    "connections.json" = base64encode(jsonencode([
      for conn in var.connections : {
        conn_id     = conn.conn_id
        conn_type   = conn.conn_type
        description = conn.description
        host        = conn.host
        login       = conn.login
        password    = conn.password
        schema      = conn.schema
        port        = conn.port
        extra       = conn.extra
      }
    ]))
  }

  type = "Opaque"
}