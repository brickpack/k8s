# terraform/modules/github-actions-runner/main.tf

resource "kubernetes_namespace" "github_actions" {
  metadata {
    name = var.github_namespace
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

resource "helm_release" "actions_runner_controller" {
  name       = "actions-runner-controller"
  namespace  = kubernetes_namespace.github_actions.metadata[0].name
  repository = "https://actions-runner-controller.github.io/actions-runner-controller"
  chart      = "actions-runner-controller"
  version    = "0.24.1" # Use the latest stable version

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
    kubernetes_secret.github_actions_secret
  ]
}

# Deploy the Runner Deployment or RunnerSet
resource "helm_release" "runner_set" {
  name       = "runner-set"
  namespace  = kubernetes_namespace.github_actions.metadata[0].name
  repository = "https://actions-runner-controller.github.io/actions-runner-controller"
  chart      = "actions-runner-controller-runner-set"
  version    = "0.24.1"

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