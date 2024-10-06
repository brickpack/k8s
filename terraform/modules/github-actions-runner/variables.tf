
variable "github_namespace" {
  description = "GitHub Actions namespace"
  type        = string
}

variable "github_pat" {
  description = "GitHub Personal Access Token for Actions Runner"
  type        = string
  sensitive   = true
}

variable "github_owner" {
  description = "GitHub repository owner (user or organization)"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "runner_replicas" {
  description = "Number of runner replicas"
  type        = number
  default     = 2
}