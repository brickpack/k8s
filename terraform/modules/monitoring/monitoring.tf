resource "kubernetes_secret" "grafana_smtp" {
  metadata {
    name      = "grafana-smtp"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    # smtp_password = base64encode(var.smtp_password)
    smtp_password = var.smtp_password
  }

  type = "Opaque" # Optional: defaults to "Opaque"
}

# Prometheus
resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "25.26.0" # Specify the chart version

  set {
    name  = "server.persistentVolume.enabled"
    value = "true"
  }
  set {
    name  = "server.persistentVolume.size"
    value = "5Gi"
  }
  set {
    name  = "server.persistentVolume.storageClass"
    value = "standard" # Use your desired storage class
  }
}


# Loki
resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "2.10.2" # Specify the chart version

  values = [
    <<-EOF
    loki:
      enabled: true
      persistence:
        enabled: true
        size: 5Gi
      config:
        auth_enabled: false
        server:
          http_listen_port: 3100
          grpc_listen_port: 9095
        distributor:
          ring:
            kvstore:
              store: inmemory
        ingester:
          lifecycler:
            address: 127.0.0.1
            ring:
              kvstore:
                store: inmemory
              replication_factor: 1
        schema_config:
          configs:
            - from: 2020-10-24
              store: boltdb-shipper
              object_store: filesystem
              schema: v11
              index:
                prefix: index_
                period: 24h
        storage_config:
          boltdb_shipper:
            active_index_directory: /data/loki/boltdb-shipper-active
            cache_location: /data/loki/boltdb-shipper-cache
            cache_ttl: 24h
            shared_store: filesystem
          filesystem:
            directory: /data/loki/chunks
        limits_config:
          enforce_metric_name: false
          reject_old_samples: true
          reject_old_samples_max_age: 168h
        chunk_store_config:
          max_look_back_period: 0s
        table_manager:
          retention_deletes_enabled: false
          retention_period: 0s
        compactor:
          working_directory: /data/loki/boltdb-shipper-compactor
          shared_store: filesystem
        memberlist:
          join_members: []
    promtail:
      enabled: true
    EOF
  ]

  set {
    name  = "loki.readinessProbe.initialDelaySeconds"
    value = "60"
  }

  set {
    name  = "loki.livenessProbe.initialDelaySeconds"
    value = "60"
  }
}


# Grafana
resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "8.4.4" # Specify the chart version

  set {
    name  = "persistence.enabled"
    value = "true"
  }
  set {
    name  = "persistence.size"
    value = "5Gi"
  }
  set {
    name  = "persistence.storageClassName"
    value = "standard" # Use your desired storage class
  }
  set {
    name  = "adminPassword"
    value = var.grafana_admin_password
  }

  values = [
    <<-EOF
    datasources:
      datasources.yaml:
        apiVersion: 1
        datasources:
        - name: Prometheus
          type: prometheus
          url: http://prometheus-server.${kubernetes_namespace.monitoring.metadata[0].name}.svc.cluster.local
          access: proxy
          isDefault: true
        - name: Loki
          type: loki
          url: http://loki.monitoring:3100
          access: proxy
          jsonData:
            maxLines: 1000
            timeout: 60
            derivedFields:
              - datasourceUid: P8E80F9AEF21F6940
                matcherRegex: "traceID=(\\w+)"
                name: TraceID
                url: "$${__value.raw}"
            healthCheck:
              enabled: true
              query: "{job=\"loki\"}"
          editable: true

    grafana.ini:
      smtp:
        enabled: true
        host: smtp.gmail.com:587
        user: dave.birkbeck.signinwith@gmail.com
        from_address: dave.birkbeck.signinwith@gmail.com
        from_name: Grafana
        skip_verify: false
        tls_enabled: true

    envVars:
      - name: GF_SMTP_PASSWORD
        valueFrom:
          secretKeyRef:
            name: grafana-smtp
            key: smtp_password
    EOF
  ]

  depends_on = [
    helm_release.loki,
    kubernetes_secret.grafana_smtp
  ]

}


# resource "helm_release" "grafana" {
#   name       = "grafana"
#   repository = "https://grafana.github.io/helm-charts"
#   chart      = "grafana"
#   namespace  = kubernetes_namespace.monitoring.metadata[0].name
#   version    = "8.4.4" # Specify the chart version

#   set {
#     name  = "persistence.enabled"
#     value = "true"
#   }
#   set {
#     name  = "persistence.size"
#     value = "5Gi"
#   }
#   set {
#     name  = "persistence.storageClassName"
#     value = "standard" # Use your desired storage class
#   }
#   set {
#     name  = "adminPassword"
#     value = var.grafana_admin_password
#   }

#   values = [
#     <<-EOF
#     datasources:
#       datasources.yaml:
#         apiVersion: 1
#         datasources:
#         - name: Prometheus
#           type: prometheus
#           url: http://prometheus-server.${kubernetes_namespace.monitoring.metadata[0].name}.svc.cluster.local
#           access: proxy
#           isDefault: true
#         - name: Loki
#           type: loki
#           url: http://loki.monitoring:3100
#           access: proxy
#           jsonData:
#             maxLines: 1000
#             timeout: 60
#             derivedFields:
#               - datasourceUid: P8E80F9AEF21F6940
#                 matcherRegex: "traceID=(\\w+)"
#                 name: TraceID
#                 url: "$${__value.raw}"
#             healthCheck:
#               enabled: true
#               query: "{job=\"loki\"}"
#           editable: true
#     EOF
#   ]

#   depends_on = [helm_release.loki]
# }