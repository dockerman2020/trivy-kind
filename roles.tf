resource "kubernetes_manifest" "role_trivy_redis_trivy" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "Role"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/instance" = "trivy"
        "app.kubernetes.io/managed-by" = "Terraform"
        "app.kubernetes.io/name" = "trivy"
        "app.kubernetes.io/version" = "0.41.0"
        "kind.tf/chart" = "trivy-0.7.0"
      }
      "name" = "trivy"
      "namespace" = "trivy-redis"
    }
  }
}

resource "kubernetes_manifest" "rolebinding_trivy_redis_trivy" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "RoleBinding"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/instance" = "trivy"
        "app.kubernetes.io/managed-by" = "Terraform"
        "app.kubernetes.io/name" = "trivy"
        "app.kubernetes.io/version" = "0.41.0"
        "kind.tf/chart" = "trivy-0.7.0"
      }
      "name" = "trivy"
      "namespace" = "trivy-redis"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "Role"
      "name" = "trivy"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "trivy"
      },
    ]
  }
}