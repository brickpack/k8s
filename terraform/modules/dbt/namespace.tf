resource "kubernetes_namespace" "dbt_namespace" {
  metadata {
    name = "dbt"
  }
}