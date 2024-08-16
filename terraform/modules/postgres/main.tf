resource "kubernetes_namespace" "database" {
  metadata {
    name = "database"
  }
}

resource "kubernetes_secret" "postgresql_secret" {
  metadata {
    name      = "postgresql-secret"
    namespace = kubernetes_namespace.database.metadata[0].name
  }
  data = {
    # POSTGRES_USER     = base64encode("your_username")
    POSTGRES_USER     = var.pg_user
    POSTGRES_PASSWORD = var.pg_pass
  }
}

resource "kubernetes_persistent_volume_claim" "postgres_pvc_14" {
  metadata {
    name      = "postgres-pvc-14"
    namespace = kubernetes_namespace.database.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "postgres_pvc_15" {
  metadata {
    name      = "postgres-pvc-15"
    namespace = kubernetes_namespace.database.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "postgres_pvc_16" {
  metadata {
    name      = "postgres-pvc-16"
    namespace = kubernetes_namespace.database.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
}

resource "kubernetes_config_map" "postgresql_config_14" {
  metadata {
    name      = "postgresql-config-14"
    namespace = kubernetes_namespace.database.metadata[0].name
  }
  data = {
    POSTGRES_DB = var.pg_db
  }
}

resource "kubernetes_config_map" "postgresql_config_15" {
  metadata {
    name      = "postgresql-config-15"
    namespace = kubernetes_namespace.database.metadata[0].name
  }
  data = {
    POSTGRES_DB = var.pg_db
  }
}

resource "kubernetes_config_map" "postgresql_config_16" {
  metadata {
    name      = "postgresql-config-16"
    namespace = kubernetes_namespace.database.metadata[0].name
  }
  data = {
    POSTGRES_DB = var.pg_db
  }
}

resource "kubernetes_stateful_set" "postgresql_14" {
  metadata {
    name      = "postgresql-14"
    namespace = kubernetes_namespace.database.metadata[0].name
  }
  spec {
    service_name = "postgresql-14"
    replicas     = 1
    selector {
      match_labels = {
        app = "postgresql-14"
      }
    }
    template {
      metadata {
        labels = {
          app = "postgresql-14"
        }
      }
      spec {
        container {
          name  = "postgresql"
          image = "postgres:14"
          port {
            container_port = 5432
          }
          env {
            name  = "POSTGRES_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgresql_secret.metadata[0].name
                key  = "POSTGRES_USER"
              }
            }
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgresql_secret.metadata[0].name
                key  = "POSTGRES_PASSWORD"
              }
            }
          }
          env {
            name = "POSTGRES_DB"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.postgresql_config_14.metadata[0].name
                key  = "POSTGRES_DB"
              }
            }
          }
          volume_mount {
            name       = "postgres-storage"
            mount_path = "/var/lib/postgresql/data"
          }
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "postgres-storage"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "10Gi"
          }
        }
      }
    }
  }
}

resource "kubernetes_stateful_set" "postgresql_15" {
  metadata {
    name      = "postgresql-15"
    namespace = kubernetes_namespace.database.metadata[0].name
  }
  spec {
    service_name = "postgresql-15"
    replicas     = 1
    selector {
      match_labels = {
        app = "postgresql-15"
      }
    }
    template {
      metadata {
        labels = {
          app = "postgresql-15"
        }
      }
      spec {
        container {
          name  = "postgresql"
          image = "postgres:15"
          port {
            container_port = 5432
          }
          env {
            name  = "POSTGRES_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgresql_secret.metadata[0].name
                key  = "POSTGRES_USER"
              }
            }
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgresql_secret.metadata[0].name
                key  = "POSTGRES_PASSWORD"
              }
            }
          }
          env {
            name = "POSTGRES_DB"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.postgresql_config_15.metadata[0].name
                key  = "POSTGRES_DB"
              }
            }
          }
          volume_mount {
            name       = "postgres-storage"
            mount_path = "/var/lib/postgresql/data"
          }
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "postgres-storage"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "10Gi"
          }
        }
      }
    }
  }
}

resource "kubernetes_stateful_set" "postgresql_16" {
  metadata {
    name      = "postgresql-16"
    namespace = kubernetes_namespace.database.metadata[0].name
  }
  spec {
    service_name = "postgresql-16"
    replicas     = 1
    selector {
      match_labels = {
        app = "postgresql-16"
      }
    }
    template {
      metadata {
        labels = {
          app = "postgresql-16"
        }
      }
      spec {
        container {
          name  = "postgresql"
          image = "postgres:16"
          port {
            container_port = 5432
          }
          env {
            name  = "POSTGRES_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgresql_secret.metadata[0].name
                key  = "POSTGRES_USER"
              }
            }
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgresql_secret.metadata[0].name
                key  = "POSTGRES_PASSWORD"
              }
            }
          }
          env {
            name = "POSTGRES_DB"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.postgresql_config_16.metadata[0].name
                key  = "POSTGRES_DB"
              }
            }
          }
          volume_mount {
            name       = "postgres-storage"
            mount_path = "/var/lib/postgresql/data"
          }
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "postgres-storage"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "10Gi"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgresql_14_service" {
  metadata {
    name      = "postgresql-14-service"
    namespace = kubernetes_namespace.database.metadata[0].name
  }
  spec {
    selector = {
      app = "postgresql-14"
    }
    port {
      protocol = "TCP"
      port     = 5432
      target_port = 5432
    }
  }
}

resource "kubernetes_service" "postgresql_15_service" {
  metadata {
    name      = "postgresql-15-service"
    namespace = kubernetes_namespace.database.metadata[0].name
  }
  spec {
    selector = {
      app = "postgresql-15"
    }
    port {
      protocol = "TCP"
      port     = 5432
      target_port = 5432
    }
  }
}

resource "kubernetes_service" "postgresql_16_service" {
  metadata {
    name      = "postgresql-16-service"
    namespace = kubernetes_namespace.database.metadata[0].name
  }
  spec {
    selector = {
      app = "postgresql-16"
    }
    port {
      protocol = "TCP"
      port     = 5432
      target_port = 5432
    }
  }
}