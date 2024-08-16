resource "kubernetes_persistent_volume_claim" "airflow_logs" {
  metadata {
    name      = "airflow-logs"
    namespace = kubernetes_namespace.airflow.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
    storage_class_name = "hostpath"
  }
}
