resource "kubernetes_manifest" "statefulset_trivy_redis_redis_master" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "StatefulSet"
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
      "persistentVolumeClaimRetentionPolicy" = {
        "whenDeleted" = "Retain"
        "whenScaled" = "Retain"
      }
      "podManagementPolicy" = "OrderedReady"
      "replicas" = 1
      "revisionHistoryLimit" = 10
      "selector" = {
        "matchLabels" = {
          "app.kubernetes.io/component" = "master"
          "app.kubernetes.io/instance" = "redis"
          "app.kubernetes.io/name" = "redis"
        }
      }
      "serviceName" = "redis-headless"
      "template" = {
        "metadata" = {
          "annotations" = {
            "checksum/configmap" = "737ad246ce288c3ad20cc549d58306240b382e23d592cfbfd2a790d82f08c9ae"
            "checksum/health" = "8b08f027041b1896a16bbefa4136eaf004cdff39b3ae9ec32c78c5c3b81b2fbe"
            "checksum/scripts" = "d1047c2846404febaaff6eb1b236684ab912b2086b3ed20741a3afe74b0cad49"
            "checksum/secret" = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
          }
          "labels" = {
            "app.kubernetes.io/component" = "master"
            "app.kubernetes.io/instance" = "redis"
            "app.kubernetes.io/managed-by" = "Terraform"
            "app.kubernetes.io/name" = "redis"
            "kind.tf/chart" = "redis-17.10.3"
          }
        }
        "spec" = {
          "affinity" = {
            "podAntiAffinity" = {
              "preferredDuringSchedulingIgnoredDuringExecution" = [
                {
                  "podAffinityTerm" = {
                    "labelSelector" = {
                      "matchLabels" = {
                        "app.kubernetes.io/component" = "master"
                        "app.kubernetes.io/instance" = "redis"
                        "app.kubernetes.io/name" = "redis"
                      }
                    }
                    "namespaces" = [
                      "trivy-redis",
                    ]
                    "topologyKey" = "kubernetes.io/hostname"
                  }
                  "weight" = 1
                },
              ]
            }
          }
          "containers" = [
            {
              "args" = [
                "-c",
                "/opt/bitnami/scripts/start-scripts/start-master.sh",
              ]
              "command" = [
                "/bin/bash",
              ]
              "env" = [
                {
                  "name" = "BITNAMI_DEBUG"
                  "value" = "false"
                },
                {
                  "name" = "REDIS_REPLICATION_MODE"
                  "value" = "master"
                },
                {
                  "name" = "ALLOW_EMPTY_PASSWORD"
                  "value" = "yes"
                },
                {
                  "name" = "REDIS_TLS_ENABLED"
                  "value" = "no"
                },
                {
                  "name" = "REDIS_PORT"
                  "value" = "6379"
                },
              ]
              "image" = "docker.io/bitnami/redis:7.0.11-debian-11-r7"
              "imagePullPolicy" = "IfNotPresent"
              "livenessProbe" = {
                "exec" = {
                  "command" = [
                    "sh",
                    "-c",
                    "/health/ping_liveness_local.sh 5",
                  ]
                }
                "failureThreshold" = 5
                "initialDelaySeconds" = 20
                "periodSeconds" = 5
                "successThreshold" = 1
                "timeoutSeconds" = 6
              }
              "name" = "redis"
              "ports" = [
                {
                  "containerPort" = 6379
                  "name" = "redis"
                  "protocol" = "TCP"
                },
              ]
              "readinessProbe" = {
                "exec" = {
                  "command" = [
                    "sh",
                    "-c",
                    "/health/ping_readiness_local.sh 1",
                  ]
                }
                "failureThreshold" = 5
                "initialDelaySeconds" = 20
                "periodSeconds" = 5
                "successThreshold" = 1
                "timeoutSeconds" = 2
              }
              "resources" = {}
              "securityContext" = {
                "runAsUser" = 1001
              }
              "terminationMessagePath" = "/dev/termination-log"
              "terminationMessagePolicy" = "File"
              "volumeMounts" = [
                {
                  "mountPath" = "/opt/bitnami/scripts/start-scripts"
                  "name" = "start-scripts"
                },
                {
                  "mountPath" = "/health"
                  "name" = "health"
                },
                {
                  "mountPath" = "/data"
                  "name" = "redis-data"
                },
                {
                  "mountPath" = "/opt/bitnami/redis/mounted-etc"
                  "name" = "config"
                },
                {
                  "mountPath" = "/opt/bitnami/redis/etc/"
                  "name" = "redis-tmp-conf"
                },
                {
                  "mountPath" = "/tmp"
                  "name" = "tmp"
                },
              ]
            },
          ]
          "dnsPolicy" = "ClusterFirst"
          "restartPolicy" = "Always"
          "schedulerName" = "default-scheduler"
          "securityContext" = {
            "fsGroup" = 1001
          }
          "serviceAccount" = "redis"
          "serviceAccountName" = "redis"
          "terminationGracePeriodSeconds" = 30
          "volumes" = [
            {
              "configMap" = {
                "defaultMode" = 493
                "name" = "redis-scripts"
              }
              "name" = "start-scripts"
            },
            {
              "configMap" = {
                "defaultMode" = 493
                "name" = "redis-health"
              }
              "name" = "health"
            },
            {
              "configMap" = {
                "defaultMode" = 420
                "name" = "redis-configuration"
              }
              "name" = "config"
            },
            {
              "emptyDir" = {}
              "name" = "redis-tmp-conf"
            },
            {
              "emptyDir" = {}
              "name" = "tmp"
            },
          ]
        }
      }
      "updateStrategy" = {
        "rollingUpdate" = {
          "partition" = 0
        }
        "type" = "RollingUpdate"
      }
      "volumeClaimTemplates" = [
        {
          "apiVersion" = "v1"
          "kind" = "PersistentVolumeClaim"
          "metadata" = {
            "creationTimestamp" = null
            "labels" = {
              "app.kubernetes.io/component" = "master"
              "app.kubernetes.io/instance" = "redis"
              "app.kubernetes.io/name" = "redis"
            }
            "name" = "redis-data"
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
            "volumeMode" = "Filesystem"
          }
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "statefulset_trivy_redis_trivy" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "StatefulSet"
    "metadata" = {
      "annotations" = {
        "meta.helm.sh/release-name" = "trivy"
        "meta.helm.sh/release-namespace" = "trivy-redis"
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
      "persistentVolumeClaimRetentionPolicy" = {
        "whenDeleted" = "Retain"
        "whenScaled" = "Retain"
      }
      "podManagementPolicy" = "Parallel"
      "replicas" = 1
      "revisionHistoryLimit" = 10
      "selector" = {
        "matchLabels" = {
          "app.kubernetes.io/instance" = "trivy"
          "app.kubernetes.io/name" = "trivy"
        }
      }
      "serviceName" = "trivy"
      "template" = {
        "metadata" = {
          "annotations" = {
            "checksum/config" = "4b55aa3d1e1f64509865d308e403ab50bb77f94921cd5601fcdab65e5a0b3188"
          }
          "labels" = {
            "app.kubernetes.io/instance" = "trivy"
            "app.kubernetes.io/name" = "trivy"
          }
        }
        "spec" = {
          "automountServiceAccountToken" = false
          "containers" = [
            {
              "args" = [
                "server",
              ]
              "envFrom" = [
                {
                  "configMapRef" = {
                    "name" = "trivy"
                  }
                },
                {
                  "secretRef" = {
                    "name" = "trivy-tok"
                  }
                },
              ]
              "image" = "aquasec/trivy:0.41.0"
              "imagePullPolicy" = "IfNotPresent"
              "livenessProbe" = {
                "failureThreshold" = 10
                "httpGet" = {
                  "path" = "/healthz"
                  "port" = "trivy-http"
                  "scheme" = "HTTP"
                }
                "initialDelaySeconds" = 5
                "periodSeconds" = 10
                "successThreshold" = 1
                "timeoutSeconds" = 1
              }
              "name" = "main"
              "ports" = [
                {
                  "containerPort" = 4954
                  "name" = "trivy-http"
                  "protocol" = "TCP"
                },
              ]
              "readinessProbe" = {
                "failureThreshold" = 3
                "httpGet" = {
                  "path" = "/healthz"
                  "port" = "trivy-http"
                  "scheme" = "HTTP"
                }
                "initialDelaySeconds" = 5
                "periodSeconds" = 10
                "successThreshold" = 1
                "timeoutSeconds" = 1
              }
              "resources" = {
                "limits" = {
                  "cpu" = "1"
                  "memory" = "1Gi"
                }
                "requests" = {
                  "cpu" = "200m"
                  "memory" = "512Mi"
                }
              }
              "securityContext" = {
                "privileged" = false
                "readOnlyRootFilesystem" = true
              }
              "terminationMessagePath" = "/dev/termination-log"
              "terminationMessagePolicy" = "File"
              "volumeMounts" = [
                {
                  "mountPath" = "/tmp"
                  "name" = "tmp-data"
                },
                {
                  "mountPath" = "/home/scanner/.cache"
                  "name" = "data"
                },
              ]
            },
          ]
          "dnsPolicy" = "ClusterFirst"
          "restartPolicy" = "Always"
          "schedulerName" = "default-scheduler"
          "securityContext" = {
            "fsGroup" = 65534
            "runAsNonRoot" = true
            "runAsUser" = 65534
          }
          "serviceAccount" = "trivy"
          "serviceAccountName" = "trivy"
          "terminationGracePeriodSeconds" = 30
          "volumes" = [
            {
              "emptyDir" = {}
              "name" = "tmp-data"
            },
          ]
        }
      }
      "updateStrategy" = {
        "rollingUpdate" = {
          "partition" = 0
        }
        "type" = "RollingUpdate"
      }
      "volumeClaimTemplates" = [
        {
          "apiVersion" = "v1"
          "kind" = "PersistentVolumeClaim"
          "metadata" = {
            "name" = "data"
          }
          "spec" = {
            "accessModes" = [
              "ReadWriteOnce",
            ]
            "resources" = {
              "requests" = {
                "storage" = "5Gi"
              }
            }
            "volumeMode" = "Filesystem"
          }
        },
      ]
    }
  }
  depends_on = [ 
    kubernetes_manifest.statefulset_trivy_redis_redis_master
   ]
}