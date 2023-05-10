resource "kubernetes_manifest" "serviceaccount_trivy_redis_redis" {
  manifest = {
    "apiVersion" = "v1"
    "automountServiceAccountToken" = true
    "kind" = "ServiceAccount"
    "metadata" = {
      "annotations" = {
        "meta.kind.tf/release-name" = "redis"
        "meta.kind.tf/release-namespace" = "trivy-redis"
      }
      "labels" = {
        "app.kubernetes.io/instance" = "redis"
        "app.kubernetes.io/managed-by" = "Terraform"
        "app.kubernetes.io/name" = "redis"
        "kind.tf/chart" = "redis-17.10.3"
      }
      "name" = "redis"
      "namespace" = "trivy-redis"
    }
  }
}

resource "kubernetes_manifest" "serviceaccount_trivy_redis_trivy" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "ServiceAccount"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/instance" = "trivy"
        "app.kubernetes.io/managed-by" = "Terraform"
        "app.kubernetes.io/name" = "trivy"
        "app.kubernetes.io/version" = "0.41.0"
      }
      "name" = "trivy"
      "namespace" = "trivy-redis"
    }
  }
}
