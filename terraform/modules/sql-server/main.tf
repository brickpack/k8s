
resource "helm_release" "sql_server" {
  name       = var.sql_helm_release_name
  namespace  = kubernetes_namespace.sql_server.metadata[0].name
  chart      = "${path.module}/helm"

  values = [
    yamlencode({
      env = {
        SA_PASSWORD = var.sql_server_sa_password
        ACCEPT_EULA = var.sql_server_accept_eula
      }
      persistence = {
        size = var.sql_server_persistence_size
      }
    })
  ]

  depends_on = [kubernetes_namespace.sql_server]
  
}
