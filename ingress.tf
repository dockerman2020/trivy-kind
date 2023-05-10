resource "kubernetes_manifest" "ingress_trivy_redis_trivy" {
  manifest = {
    "apiVersion" = "networking.k8s.io/v1"
    "kind" = "Ingress"
    "metadata" = {
      "annotations" = {
        "meta.kind.tf/release-name" = "trivy"
        "meta.kind.tf/release-namespace" = "trivy-redis"
      }
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
    "spec" = {
      "ingressClassName" = "nginx"
      "rules" = [
        {
          "host" = "trivy.absi.test"
          "http" = {
            "paths" = [
              {
                "backend" = {
                  "service" = {
                    "name" = "trivy"
                    "port" = {
                      "number" = 4954
                    }
                  }
                }
                "path" = "/"
                "pathType" = "Prefix"
              },
            ]
          }
        },
      ]
    }
  }
}