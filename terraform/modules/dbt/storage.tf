resource "kubernetes_persistent_volume" "dbt_data" {
  metadata {
    name = "dbt-data"
  }

  spec {
    capacity = {
      storage = "1Gi"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/mnt/data"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "dbt_data" {
  metadata {
    name      = "dbt-data-claim"
    namespace = var.dbt_namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}