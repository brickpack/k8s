resource "kubernetes_config_map" "dbt_profiles" {
  metadata {
    name      = "dbt-profiles"
    namespace = kubernetes_namespace.dbt_namespace.metadata[0].name
  }

  data = {
    "profiles.yml" = templatefile("${path.module}/profiles.yml.tpl", {
      type     = var.dbt_type
      location = var.dbt_location
      user     = var.dbt_user
      password = var.dbt_password
    })
  }
}
# resource "kubernetes_config_map" "dbt_profiles" {
#   metadata {
#     name      = "dbt-profiles"
#     namespace = kubernetes_namespace.dbt.metadata[0].name
#   }

#   data = {
#     "profiles.yml" = <<YAML
# default:
#   target: dev
#   outputs:
#     dev:
#       type: postgres
#       host: postgresql.dbt.svc.cluster.local
#       user: dbt_user
#       password: your_password
#       dbname: dbt_database
#       schema: analytics
#       threads: 4
#       keepalives_idle: 0
#       connect_timeout: 10
#       sslmode: prefer
# YAML
#   }
# }