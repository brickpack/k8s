resource "kubernetes_service" "dbt_service" {
  metadata {
    name      = "dbt-service"
    namespace = kubernetes_namespace.dbt_namespace.metadata[0].name
  }

  spec {
    selector = {
      app = "dbt"
    }

    port {
      protocol    = "TCP"
      port        = 80
      target_port = 8080
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "dbt" {
  metadata {
    name      = "dbt-deployment"
    namespace = var.dbt_namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "dbt"
      }
    }

    template {
      metadata {
        labels = {
          app = "dbt"
        }
      }

      spec {
        container {
          name  = "dbt"
          image = "ghcr.io/dbt-labs/dbt-core:latest"

          volume_mount {
            name       = "dbt-profiles"
            mount_path = "/root/.dbt"
          }

          command = ["dbt", "run"]

          env {
            name  = "DBT_PROFILES_DIR"
            value = "/root/.dbt"
          }
        }

        volume {
          name = "dbt-profiles"

          config_map {
            name = kubernetes_config_map.dbt_profiles.metadata[0].name
          }
        }
      }
    }
  }
}