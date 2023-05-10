resource "kubernetes_manifest" "persistentvolumeclaim_trivy_redis_redis_data_redis_master_0" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "PersistentVolumeClaim"
    "metadata" = {
      "annotations" = {
        "volume.beta.kubernetes.io/storage-provisioner" = "kubernetes.io/no-provisioner"
        "volume.kubernetes.io/storage-provisioner" = "kubernetes.io/no-provisioner"
        "pv.kubernetes.io/provisioned-by" = "kubernetes.io/no-provisioner"
      }
      "labels" = {
        "app.kubernetes.io/component" = "master"
        "app.kubernetes.io/instance" = "redis"
        "app.kubernetes.io/name" = "redis"
      }
      "name" = "redis-data-redis-master-0"
      "namespace" = "trivy-redis"
    }
    "spec" = {
      "accessModes" = [
        "ReadWriteOnce",
      ]
      "resources" = {
        "requests" = {
          "storage" = "8Gi"
        }
      }
      "storageClassName" = "local-storage"
    }
  }
}
