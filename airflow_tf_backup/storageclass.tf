resource "kubernetes_storage_class" "standard" {
  count = var.create_storage_class ? 1 : 0

  metadata {
    name = "standard"
  }

  storage_provisioner = "kubernetes.io/no-provisioner"  # Change this according to your environment
  reclaim_policy = "Retain"
  volume_binding_mode = "WaitForFirstConsumer"
  parameters = {
    type = "pd-standard"
  }
}
