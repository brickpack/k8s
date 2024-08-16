resource "kubernetes_storage_class" "standard" {
  count = var.create_storage_class ? 1 : 0

  metadata {
    name = "standard"
  }

  storage_provisioner = "kubernetes.io/gce-pd"
  # storage_provisioner = "docker.io/hostpath"  # Change this according to your environment
  reclaim_policy      = "Retain"
  parameters = {
    type = "pd-standard"
  }
}
