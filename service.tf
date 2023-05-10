resource "kubernetes_manifest" "service_trivy_redis_redis_headless" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
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
      "name" = "redis-headless"
      "namespace" = "trivy-redis"
    }
    "spec" = {
      "clusterIP" = "None"
      "clusterIPs" = [
        "None",
      ]
      "internalTrafficPolicy" = "Cluster"
      "ipFamilies" = [
        "IPv4",
      ]
      "ipFamilyPolicy" = "SingleStack"
      "ports" = [
        {
          "name" = "tcp-redis"
          "port" = 6379
          "protocol" = "TCP"
          "targetPort" = "redis"
        },
      ]
      "selector" = {
        "app.kubernetes.io/instance" = "redis"
        "app.kubernetes.io/name" = "redis"
      }
      "sessionAffinity" = "None"
      "type" = "ClusterIP"
    }
  }
}

resource "kubernetes_manifest" "service_trivy_redis_redis_master" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "annotations" = {
        "meta.kind.tf/release-name" = "redis"
        "meta.kind.tf/release-namespace" = "trivy-redis"
      }
      "labels" = {
        "app.kubernetes.io/component" = "master"
        "app.kubernetes.io/instance" = "redis"
        "app.kubernetes.io/managed-by" = "Terraform"
        "app.kubernetes.io/name" = "redis"
        "kind.tf/chart" = "redis-17.10.3"
      }
      "name" = "redis-master"
      "namespace" = "trivy-redis"
    }
    "spec" = {
      "internalTrafficPolicy" = "Cluster"
      "ipFamilies" = [
        "IPv4",
      ]
      "ipFamilyPolicy" = "SingleStack"
      "ports" = [
        {
          "name" = "tcp-redis"
          "port" = 6379
          "protocol" = "TCP"
          "targetPort" = "redis"
        },
      ]
      "selector" = {
        "app.kubernetes.io/component" = "master"
        "app.kubernetes.io/instance" = "redis"
        "app.kubernetes.io/name" = "redis"
      }
      "sessionAffinity" = "None"
      "type" = "ClusterIP"
    }
  }
}

resource "kubernetes_manifest" "service_trivy_redis_redis_replicas" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "annotations" = {
        "meta.kind.tf/release-name" = "redis"
        "meta.kind.tf/release-namespace" = "trivy-redis"
      }
      "labels" = {
        "app.kubernetes.io/component" = "replica"
        "app.kubernetes.io/instance" = "redis"
        "app.kubernetes.io/managed-by" = "Terraform"
        "app.kubernetes.io/name" = "redis"
        "kind.tf/chart" = "redis-17.10.3"
      }
      "name" = "redis-replicas"
      "namespace" = "trivy-redis"
    }
    "spec" = {
      "internalTrafficPolicy" = "Cluster"
      "ipFamilies" = [
        "IPv4",
      ]
      "ipFamilyPolicy" = "SingleStack"
      "ports" = [
        {
          "name" = "tcp-redis"
          "port" = 6379
          "protocol" = "TCP"
          "targetPort" = "redis"
        },
      ]
      "selector" = {
        "app.kubernetes.io/component" = "replica"
        "app.kubernetes.io/instance" = "redis"
        "app.kubernetes.io/name" = "redis"
      }
      "sessionAffinity" = "None"
      "type" = "ClusterIP"
    }
  }
}

resource "kubernetes_manifest" "service_trivy" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/instance" = "trivy"
        "app.kubernetes.io/managed-by" = "Terraform"
        "app.kubernetes.io/name" = "trivy"
        "app.kubernetes.io/version" = "0.41.0"
        "kind.sh/chart" = "trivy-0.7.0"
      }
      "name" = "trivy"
      "namespace" = data.kubernetes_resource.trivy-redis_ns.metadata[0].namespace
    }
    "spec" = {
      "ports" = [
        {
          "name" = "trivy-http"
          "port" = 4954
          "protocol" = "TCP"
          "targetPort" = 4954
        },
      ]
      "selector" = {
        "app.kubernetes.io/instance" = "trivy"
        "app.kubernetes.io/name" = "trivy"
      }
      "sessionAffinity" = "ClientIP"
      "type" = "ClusterIP"
    }
  }
}