# terraform/modules/github-actions-runner/outputs.tf

output "github_actions_runner_namespace" {
  description = "Namespace where GitHub Actions Runner is deployed"
  value       = kubernetes_namespace.github_actions.metadata[0].name
}

output "runner_set_status" {
  description = "Status of the Runner Set"
  value       = helm_release.runner_set.status
}