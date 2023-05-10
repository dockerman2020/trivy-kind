resource "kubernetes_manifest" "persistentvolume_redis_pv_volume" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "PersistentVolume"
    "metadata" = {
      "annotations" = {
        "pv.kubernetes.io/provisioned-by" = "kubernetes.io/no-provisioner"
      }
      "name" = "redis-pv-volume"
    }
    "spec" = {
      "accessModes" = [
        "ReadWriteOnce",
      ]
      "capacity" = {
        "storage" = "8Gi"
      }
      "claimRef" = {
        "apiVersion" = "v1"
        "kind" = "PersistentVolumeClaim"
        "name" = "redis-data-redis-master-0"
        "namespace" = "trivy-redis"
      }
      "local" = {
        "path" = "/ContainerData/Redis"
      }
      "nodeAffinity" = {
        "required" = {
          "nodeSelectorTerms" = [
            {
              "matchExpressions" = [
                {
                  "key" = "kubernetes.io/hostname"
                  "operator" = "In"
                  "values" = [
                    "terraform-worker",
                    "terraform-worker2",
                    "terraform-worker3",
                  ]
                },
              ]
            },
          ]
        }
      }
      "storageClassName" = "local-storage"
    }
  }
}
