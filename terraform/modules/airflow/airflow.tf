resource "helm_release" "postgresql" {
  name       = "${var.airflow_release_name}-pg"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  namespace  = kubernetes_namespace.airflow.metadata[0].name

  set {
    name  = "auth.username"
    value = var.postgres_username
  }

  set {
    name  = "auth.password"
    value = var.postgres_password
  }

  set {
    name  = "auth.database"
    value = "airflow"
  }

  set {
    name  = "primary.persistence.enabled"
    value = "false"  # Disable persistence for testing. Enable it in production.
  }
}

resource "kubernetes_job" "airflow_db_init" {
  depends_on = [helm_release.postgresql]

  metadata {
    name      = "${var.airflow_release_name}-db-init"
    namespace = kubernetes_namespace.airflow.metadata[0].name
  }
  spec {
    template {
      metadata {
        name = "airflow-db-init"
      }
      spec {
        container {
          name    = "airflow-db-init"
          image   = "apache/airflow:${var.airflow_version}"
          command = ["/bin/bash", "-c", "echo 'Starting DB init' && airflow db init && airflow db upgrade && echo 'DB init complete'"]
          env {
            name  = "AIRFLOW__CORE__SQL_ALCHEMY_CONN"
            value = "postgresql://${var.postgres_username}:${var.postgres_password}@${var.airflow_release_name}-pg-postgresql.${kubernetes_namespace.airflow.metadata[0].name}.svc.cluster.local:5432/airflow"
          }
          env {
            name  = "AIRFLOW__CORE__EXECUTOR"
            value = "LocalExecutor"
          }
        }
        restart_policy = "OnFailure"
      }
    }
    backoff_limit = 5
  }

  wait_for_completion = true

  timeouts {
    create = "10m"
    update = "10m"
  }
}

# resource "helm_release" "airflow" {
#   name       = var.airflow_release_name
#   repository = "https://airflow.apache.org"
#   chart      = "airflow"
#   version    = var.airflow_chart_version
#   namespace  = kubernetes_namespace.airflow.metadata[0].name

#   depends_on = [
#     kubernetes_job.airflow_db_init,
#     kubernetes_namespace.airflow,
#     kubernetes_persistent_volume_claim.airflow_logs,
#     kubernetes_secret.airflow_secrets
#   ]

#   values = [
#     yamlencode({
#       config = {
#         fernetKey = {
#           value = var.fernet_key
#         }
#         core = {
#           fernetKey = var.fernet_key,
#           killed_task_cleanup_time = "60"
#         }
#         scheduler = {
#           scheduler_zombie_task_threshold = "300"
#           use_row_level_locking            = "true"
#         }
#         webserver = {
#           worker_refresh_interval    = "30"
#           worker_refresh_batch_size  = "1"
#           secret_key                 = var.webserver_secret_key
#         }
#       }
#       postgresql = {
#         enabled = true
#       }
#       data = {
#         metadataConnection = {
#           user     = var.postgres_username
#           pass     = var.postgres_password
#           host     = "${var.airflow_release_name}-pg-postgresql.${kubernetes_namespace.airflow.metadata[0].name}.svc.cluster.local"
#           port     = 5432
#           db       = "airflow"
#           protocol = "postgresql"
#         }
#       }
#       webserver = {
#         defaultUser = {
#           enabled  = true
#           username = "admin"
#           password = var.webserver_password
#         }
#       }
#       workers = {
#         terminationGracePeriodSeconds = 600
#       }
#       triggerer = {
#         logGroomerSidecar = {
#           enabled = true
#         }
#         persistence = {
#           enabled           = true
#           size              = "5Gi"
#           storageClassName  = "standard" # Use your desired storage class
#         }
#       }
#       executor = "KubernetesExecutor"
#       env = [
#         {
#           name  = "AIRFLOW__CORE__DAGBAG_IMPORT_TIMEOUT"
#           value = "120"
#         },
#         {
#           name  = "AIRFLOW__CORE__INIT_RETRY_DELAY"
#           value = "30"
#         },
#         {
#           name  = "AIRFLOW__CORE__MAX_INIT_RETRY"
#           value = "10"
#         }
#       ]
#       airflowPodAnnotations = {
#         "promtail.io/scrape" = "true"
#         "promtail.io/port"   = "3100"
#       }
#       dags = {
#         gitSync = {
#           enabled = true
#           repo    = var.git_repo
#           branch  = var.git_branch
#           subPath = "dags"
#           wait    = 60
#         }
#       }
#     })
#   ]

#   set {
#     name  = "dags.gitSync.enabled"
#     value = "true"
#   }

#   set {
#     name  = "dags.gitSync.repo"
#     value = var.git_repo
#   }

#   set {
#     name  = "dags.gitSync.branch"
#     value = var.git_branch
#   }

#   set {
#     name  = "dags.gitSync.subPath"
#     value = "dags"
#   }

#   set {
#     name  = "dags.gitSync.wait"
#     value = "60"
#   }

#   set {
#     name  = "airflow.image.tag"
#     value = var.airflow_chart_version
#   }

#   set {
#     name  = "postgresql.enabled"
#     value = "true"
#   }

#   set {
#     name  = "workers.persistence.enabled"
#     value = "true"
#   }

#   set {
#     name  = "workers.persistence.size"
#     value = "5Gi"
#   }

#   timeout = 1200 # 20 minutes
# }

# resource "helm_release" "airflow" {
#   # Name of the Airflow release in Kubernetes
#   name       = var.airflow_release_name
  
#   # Repository and chart details for Airflow Helm chart
#   repository = "https://airflow.apache.org"
#   chart      = "airflow"
#   version    = var.airflow_chart_version

#   # Namespace where Airflow will be deployed
#   namespace  = kubernetes_namespace.airflow.metadata[0].name

#   # Dependencies to ensure these resources are created before deploying Airflow
#   depends_on = [
#     kubernetes_job.airflow_db_init,
#     kubernetes_namespace.airflow,
#     kubernetes_persistent_volume_claim.airflow_logs,
#     kubernetes_secret.airflow_secrets
#   ]

#   # YAML configuration values passed to the Helm chart
#   values = [
#     yamlencode({
#       config = {
#         core = {
#           # Fernet key for encrypting sensitive data (must be set)
#           fernet_key = var.fernet_key
#           # Time (in seconds) to wait before cleaning up killed tasks
#           killed_task_cleanup_time = "60"
#           # Timeout (in seconds) for importing DAG files
#           dagbag_import_timeout = "120"
#           # Delay between retry attempts if initialization fails
#           init_retry_delay = "30"
#           # Maximum number of retries for initialization
#           max_init_retry = "10"
#         }
#         scheduler = {
#           # Time (in seconds) before marking a task as zombie
#           scheduler_zombie_task_threshold = "300"
#           # Ensures row-level locking to prevent race conditions
#           use_row_level_locking = "true"
#           # Number of threads the scheduler uses to process DAG files
#           max_threads = "2"
#           # Interval (in seconds) for processing files in the DAG directory
#           min_file_process_interval = "30"
#           # Interval (in seconds) for checking the DAG directory for updates
#           dag_dir_list_interval = "60"
#           # Maximum number of active DAG runs per DAG
#           max_active_runs_per_dag = "16"
#           # Maximum number of active tasks per DAG
#           max_active_tasks_per_dag = "32"
#         }
#         webserver = {
#           # Time (in seconds) before refreshing workers
#           worker_refresh_interval = "120"
#           # Number of workers to refresh at a time
#           worker_refresh_batch_size = "1"
#           # Secret key for session encryption in the webserver
#           secret_key = var.webserver_secret_key
#         }
#       }
#       postgresql = {
#         # Enable the built-in PostgreSQL database (for testing environments)
#         enabled = true
#       }
#       data = {
#         metadata_connection = {
#           # Connection settings for the metadata database
#           user     = var.postgres_username
#           pass     = var.postgres_password
#           host     = "${var.airflow_release_name}-pg-postgresql.${kubernetes_namespace.airflow.metadata[0].name}.svc.cluster.local"
#           port     = 5432
#           db       = "airflow"
#           protocol = "postgresql"
#         }
#       }
#       webserver = {
#         default_user = {
#           # Default admin user for accessing the Airflow UI
#           enabled  = true
#           username = "admin"
#           password = var.webserver_password
#         }
#       }
#       workers = {
#         # Grace period (in seconds) for terminating worker pods
#         termination_grace_period_seconds = 600
#         # Resource limits and requests for worker pods
#         resources = {
#           limits = {
#             cpu = "1"
#             memory = "1Gi"
#           }
#           requests = {
#             cpu = "1"
#             memory = "1Gi"
#           }
#         }
#       }
#       triggerer = {
#         # Sidecar for grooming triggerer logs
#         log_groomer_sidecar = {
#           enabled = true
#         }
#         # Persistent storage configuration for the triggerer
#         persistence = {
#           enabled           = true
#           size              = "5Gi"
#           storage_class_name = "standard" # Use your desired storage class
#         }
#       }
#       # Using KubernetesExecutor for scaling Airflow workers dynamically
#       executor = "KubernetesExecutor"
#       env = [
#         {
#           # Environment variables for core and scheduler configurations
#           name  = "AIRFLOW__CORE__DAGBAG_IMPORT_TIMEOUT"
#           value = "120"
#         },
#         {
#           name  = "AIRFLOW__CORE__INIT_RETRY_DELAY"
#           value = "30"
#         },
#         {
#           name  = "AIRFLOW__CORE__MAX_INIT_RETRY"
#           value = "10"
#         },
#         {
#           name  = "AIRFLOW__SCHEDULER__MIN_FILE_PROCESS_INTERVAL"
#           value = "30"
#         },
#         {
#           name  = "AIRFLOW__SCHEDULER__DAG_DIR_LIST_INTERVAL"
#           value = "60"
#         }
#       ]
#       # Annotations for Promtail to scrape logs for monitoring
#       airflow_pod_annotations = {
#         "promtail.io/scrape" = "true"
#         "promtail.io/port"   = "3100"
#       }
#       dags = {
#         git_sync = {
#           # Configuration for synchronizing DAGs from a Git repository
#           enabled = true
#           repo    = var.git_repo
#           branch  = var.git_branch
#           sub_path = "dags"
#           wait    = 60
#         }
#       }
#     })
#   ]

#   # Additional settings using `set` blocks to override values
#   set {
#     name  = "dags.gitSync.enabled"
#     value = "true"
#   }

#   set {
#     name  = "dags.gitSync.repo"
#     value = var.git_repo
#   }

#   set {
#     name  = "dags.gitSync.branch"
#     value = var.git_branch
#   }

#   set {
#     name  = "dags.gitSync.subPath"
#     value = "dags"
#   }

#   set {
#     name  = "dags.gitSync.wait"
#     value = "60"
#   }

#   set {
#     name  = "airflow.image.tag"
#     value = var.airflow_chart_version
#   }

#   set {
#     name  = "postgresql.enabled"
#     value = "true"
#   }

#   set {
#     name  = "workers.persistence.enabled"
#     value = "true"
#   }

#   set {
#     name  = "workers.persistence.size"
#     value = "5Gi"
#   }

#   # Timeout for Helm release to avoid long-running installations
#   timeout = 1200 # 20 minutes
# }
resource "helm_release" "airflow" {
  name       = var.airflow_release_name
  repository = "https://airflow.apache.org"
  chart      = "airflow"
  version    = var.airflow_chart_version
  namespace  = kubernetes_namespace.airflow.metadata[0].name

  depends_on = [
    kubernetes_job.airflow_db_init,
    kubernetes_namespace.airflow,
    kubernetes_persistent_volume_claim.airflow_logs,
    kubernetes_secret.airflow_secrets
  ]

  values = [
    yamlencode({
      config = {
        core = {
          fernet_key = var.fernet_key
          killed_task_cleanup_time = "60"
          dagbag_import_timeout = "120"
          init_retry_delay = "30"
          max_init_retry = "10"
        }
        scheduler = {
          scheduler_zombie_task_threshold = "300"
          use_row_level_locking = "true"
          max_threads = "2"
          min_file_process_interval = "30"
          dag_dir_list_interval = "60"
          max_active_runs_per_dag = "16"
          max_active_tasks_per_dag = "32"
        }
        webserver = {
          worker_refresh_interval = "120"
          worker_refresh_batch_size = "1"
          secret_key = var.webserver_secret_key
        }
      }
      postgresql = {
        enabled = true
      }
      data = {
        metadataConnection = {
          user     = var.postgres_username
          pass     = var.postgres_password
          host     = "${var.airflow_release_name}-pg-postgresql.${kubernetes_namespace.airflow.metadata[0].name}.svc.cluster.local"
          port     = 5432
          db       = "airflow"
          protocol = "postgresql"
        }
      }
      web = {
        defaultUser = {
          create = true
          username = "admin"
          password = var.webserver_password
        }
      }
      workers = {
        terminationGracePeriodSeconds = 600
        persistence = {
          enabled = true
          size = "5Gi"
        }
        resources = {
          limits = {
            cpu = "2"
            memory = "4Gi"
          }
          requests = {
            cpu = "1"
            memory = "2Gi"
          }
        }
      }
      triggerer = {
        persistence = {
          enabled = true
          size = "5Gi"
        }
      }
      executor = "KubernetesExecutor"
      env = [
        {
          name  = "AIRFLOW__CORE__DAGBAG_IMPORT_TIMEOUT"
          value = "120"
        },
        {
          name  = "AIRFLOW__CORE__INIT_RETRY_DELAY"
          value = "30"
        },
        {
          name  = "AIRFLOW__CORE__MAX_INIT_RETRY"
          value = "10"
        },
        {
          name  = "AIRFLOW__SCHEDULER__MIN_FILE_PROCESS_INTERVAL"
          value = "30"
        },
        {
          name  = "AIRFLOW__SCHEDULER__DAG_DIR_LIST_INTERVAL"
          value = "60"
        }
      ]
      podAnnotations = {
        "promtail.io/scrape" = "true"
        "promtail.io/port"   = "3100"
      }
      dags = {
        gitSync = {
          enabled = true
          repo = var.git_repo
          branch = var.git_branch
          subPath = "dags"
          wait = 60
        }
      }
    })
  ]

  set {
    name  = "dags.gitSync.enabled"
    value = "true"
  }

  set {
    name  = "dags.gitSync.repo"
    value = var.git_repo
  }

  set {
    name  = "dags.gitSync.branch"
    value = var.git_branch
  }

  set {
    name  = "dags.gitSync.subPath"
    value = "dags"
  }

  set {
    name  = "dags.gitSync.wait"
    value = "60"
  }

  set {
    name  = "airflow.image.tag"
    value = var.airflow_chart_version
  }

  set {
    name  = "postgresql.enabled"
    value = "true"
  }

  set {
    name  = "workers.persistence.enabled"
    value = "true"
  }

  set {
    name  = "workers.persistence.size"
    value = "5Gi"
  }

  set {
    name  = "webserver.secret_key"
    value = var.webserver_secret_key
  }

  timeout = 1200 # 20 minutes
}