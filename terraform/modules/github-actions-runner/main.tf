
resource "kubernetes_namespace" "github_actions" {
  metadata {
    name = var.github_namespace
  }
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "kubernetes_secret" "github_actions_secret" {
  metadata {
    name      = "github-actions-secret"
    namespace = kubernetes_namespace.github_actions.metadata[0].name
  }

  type = "Opaque"

  data = {
    GITHUB_TOKEN = base64encode(var.github_pat)
  }
}

# Add actions-runner-controller Helm Repository using null_resource
resource "null_resource" "add_actions_runner_controller_repo" {
  provisioner "local-exec" {
    command = "helm repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller && helm repo update"
  }

  # Ensure this runs before any helm_release that depends on the repository
  triggers = {
    always_run = "${timestamp()}"
  }
}

# Add Jetstack Helm Repository for cert-manager using null_resource
resource "null_resource" "add_jetstack_repo" {
  provisioner "local-exec" {
    command = "helm repo add jetstack https://charts.jetstack.io && helm repo update"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

# Install cert-manager using Helm
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = kubernetes_namespace.cert_manager.metadata[0].name
  repository = "jetstack"
  chart      = "cert-manager"
  version    = "v1.11.3"  # Use the latest stable version as needed

  create_namespace = false

  values = [
    <<-EOF
      installCRDs: true
      prometheus:
        enabled: false
    EOF
  ]

  depends_on = [
    null_resource.add_jetstack_repo
  ]
}

# resource "kubernetes_manifest" "selfsigned_cluster_issuer" {
#   manifest = {
#     apiVersion = "cert-manager.io/v1"
#     kind       = "ClusterIssuer"
#     metadata = {
#       name = "selfsigned-cluster-issuer"
#     }
#     spec = {
#       selfSigned = {}
#     }
#   }

#   depends_on = [
#     helm_release.cert_manager
#   ]
# }

# Install actions-runner-controller using Helm
resource "helm_release" "actions_runner_controller" {
  name       = "actions-runner-controller"
  namespace  = kubernetes_namespace.github_actions.metadata[0].name
  repository = "actions-runner-controller"
  chart      = "actions-runner-controller"
  version    = "0.23.7"  # Use the latest available version

  create_namespace = false

  values = [
    file("${path.module}/values.yaml")
  ]

  set {
    name  = "serviceAccount.create"
    value = true
  }

  set {
    name  = "serviceAccount.name"
    value = "actions-runner-controller"
  }

  depends_on = [
    null_resource.add_actions_runner_controller_repo,
    helm_release.cert_manager,
    kubernetes_secret.github_actions_secret
  ]
}

# Install RunnerSet using Helm
resource "helm_release" "runner_set" {
  name       = "runner-set"
  namespace  = kubernetes_namespace.github_actions.metadata[0].name
  repository = "actions-runner-controller"
  chart      = "actions-runner-controller-runner-set"
  version    = "0.23.7"  # Ensure this matches available version

  create_namespace = false

  values = [
    templatefile("${path.module}/runner-set-values.yaml", {
      runner_replicas = var.runner_replicas
      github_owner     = var.github_owner
      github_repo      = var.github_repo
    })
  ]

  depends_on = [
    helm_release.actions_runner_controller
  ]
}