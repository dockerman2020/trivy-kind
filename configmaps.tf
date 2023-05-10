resource "kubernetes_manifest" "configmap_trivy_redis_redis_configuration" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "master.conf" = <<-EOT
      dir /data
      # User-supplied master configuration:
      rename-command FLUSHDB ""
      rename-command FLUSHALL ""
      # End of master configuration
      EOT
      "redis.conf" = <<-EOT
      # User-supplied common configuration:
      # Enable AOF https://redis.io/topics/persistence#append-only-file
      appendonly yes
      # Disable RDB persistence, AOF persistence already enabled.
      save ""
      # End of common configuration
      EOT
      "replica.conf" = <<-EOT
      dir /data
      # User-supplied replica configuration:
      rename-command FLUSHDB ""
      rename-command FLUSHALL ""
      # End of replica configuration
      EOT
    }
    "kind" = "ConfigMap"
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
      "name" = "redis-configuration"
      "namespace" = "trivy-redis"
    }
  }
}

resource "kubernetes_manifest" "configmap_trivy_redis_redis_health" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "ping_liveness_local.sh" = <<-EOT
      #!/bin/bash

      [[ -f $REDIS_PASSWORD_FILE ]] && export REDIS_PASSWORD="$(< "$${REDIS_PASSWORD_FILE}")"
      [[ -n "$REDIS_PASSWORD" ]] && export REDISCLI_AUTH="$REDIS_PASSWORD"
      response=$(
        timeout -s 3 $1 \
        redis-cli \
          -h localhost \
          -p $REDIS_PORT \
          ping
      )
      if [ "$?" -eq "124" ]; then
        echo "Timed out"
        exit 1
      fi
      responseFirstWord=$(echo $response | head -n1 | awk '{print $1;}')
      if [ "$response" != "PONG" ] && [ "$responseFirstWord" != "LOADING" ] && [ "$responseFirstWord" != "MASTERDOWN" ]; then
        echo "$response"
        exit 1
      fi
      EOT
      "ping_liveness_local_and_master.sh" = <<-EOT
      script_dir="$(dirname "$0")"
      exit_status=0
      "$script_dir/ping_liveness_local.sh" $1 || exit_status=$?
      "$script_dir/ping_liveness_master.sh" $1 || exit_status=$?
      exit $exit_status
      EOT
      "ping_liveness_master.sh" = <<-EOT
      #!/bin/bash

      [[ -f $REDIS_MASTER_PASSWORD_FILE ]] && export REDIS_MASTER_PASSWORD="$(< "$${REDIS_MASTER_PASSWORD_FILE}")"
      [[ -n "$REDIS_MASTER_PASSWORD" ]] && export REDISCLI_AUTH="$REDIS_MASTER_PASSWORD"
      response=$(
        timeout -s 3 $1 \
        redis-cli \
          -h $REDIS_MASTER_HOST \
          -p $REDIS_MASTER_PORT_NUMBER \
          ping
      )
      if [ "$?" -eq "124" ]; then
        echo "Timed out"
        exit 1
      fi
      responseFirstWord=$(echo $response | head -n1 | awk '{print $1;}')
      if [ "$response" != "PONG" ] && [ "$responseFirstWord" != "LOADING" ]; then
        echo "$response"
        exit 1
      fi
      EOT
      "ping_readiness_local.sh" = <<-EOT
      #!/bin/bash

      [[ -f $REDIS_PASSWORD_FILE ]] && export REDIS_PASSWORD="$(< "$${REDIS_PASSWORD_FILE}")"
      [[ -n "$REDIS_PASSWORD" ]] && export REDISCLI_AUTH="$REDIS_PASSWORD"
      response=$(
        timeout -s 3 $1 \
        redis-cli \
          -h localhost \
          -p $REDIS_PORT \
          ping
      )
      if [ "$?" -eq "124" ]; then
        echo "Timed out"
        exit 1
      fi
      if [ "$response" != "PONG" ]; then
        echo "$response"
        exit 1
      fi
      EOT
      "ping_readiness_local_and_master.sh" = <<-EOT
      script_dir="$(dirname "$0")"
      exit_status=0
      "$script_dir/ping_readiness_local.sh" $1 || exit_status=$?
      "$script_dir/ping_readiness_master.sh" $1 || exit_status=$?
      exit $exit_status
      EOT
      "ping_readiness_master.sh" = <<-EOT
      #!/bin/bash

      [[ -f $REDIS_MASTER_PASSWORD_FILE ]] && export REDIS_MASTER_PASSWORD="$(< "$${REDIS_MASTER_PASSWORD_FILE}")"
      [[ -n "$REDIS_MASTER_PASSWORD" ]] && export REDISCLI_AUTH="$REDIS_MASTER_PASSWORD"
      response=$(
        timeout -s 3 $1 \
        redis-cli \
          -h $REDIS_MASTER_HOST \
          -p $REDIS_MASTER_PORT_NUMBER \
          ping
      )
      if [ "$?" -eq "124" ]; then
        echo "Timed out"
        exit 1
      fi
      if [ "$response" != "PONG" ]; then
        echo "$response"
        exit 1
      fi
      EOT
    }
    "kind" = "ConfigMap"
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
      "name" = "redis-health"
      "namespace" = "trivy-redis"
    }
  }
}

resource "kubernetes_manifest" "configmap_trivy_redis_redis_scripts" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "start-master.sh" = <<-EOT
      #!/bin/bash

      [[ -f $REDIS_PASSWORD_FILE ]] && export REDIS_PASSWORD="$(< "$${REDIS_PASSWORD_FILE}")"
      if [[ -f /opt/bitnami/redis/mounted-etc/master.conf ]];then
          cp /opt/bitnami/redis/mounted-etc/master.conf /opt/bitnami/redis/etc/master.conf
      fi
      if [[ -f /opt/bitnami/redis/mounted-etc/redis.conf ]];then
          cp /opt/bitnami/redis/mounted-etc/redis.conf /opt/bitnami/redis/etc/redis.conf
      fi
      ARGS=("--port" "$${REDIS_PORT}")
      ARGS+=("--protected-mode" "no")
      ARGS+=("--include" "/opt/bitnami/redis/etc/redis.conf")
      ARGS+=("--include" "/opt/bitnami/redis/etc/master.conf")
      exec redis-server "$${ARGS[@]}"

      EOT
      "start-replica.sh" = <<-EOT
      #!/bin/bash

      get_port() {
          hostname="$1"
          type="$2"

          port_var=$(echo "$${hostname^^}_SERVICE_PORT_$type" | sed "s/-/_/g")
          port=$${!port_var}

          if [ -z "$port" ]; then
              case $type in
                  "SENTINEL")
                      echo 26379
                      ;;
                  "REDIS")
                      echo 6379
                      ;;
              esac
          else
              echo $port
          fi
      }

      get_full_hostname() {
          hostname="$1"
          echo "$${hostname}.$${HEADLESS_SERVICE}"
      }

      REDISPORT=$(get_port "$HOSTNAME" "REDIS")

      [[ -f $REDIS_PASSWORD_FILE ]] && export REDIS_PASSWORD="$(< "$${REDIS_PASSWORD_FILE}")"
      [[ -f $REDIS_MASTER_PASSWORD_FILE ]] && export REDIS_MASTER_PASSWORD="$(< "$${REDIS_MASTER_PASSWORD_FILE}")"
      if [[ -f /opt/bitnami/redis/mounted-etc/replica.conf ]];then
          cp /opt/bitnami/redis/mounted-etc/replica.conf /opt/bitnami/redis/etc/replica.conf
      fi
      if [[ -f /opt/bitnami/redis/mounted-etc/redis.conf ]];then
          cp /opt/bitnami/redis/mounted-etc/redis.conf /opt/bitnami/redis/etc/redis.conf
      fi

      echo "" >> /opt/bitnami/redis/etc/replica.conf
      echo "replica-announce-port $REDISPORT" >> /opt/bitnami/redis/etc/replica.conf
      echo "replica-announce-ip $(get_full_hostname "$HOSTNAME")" >> /opt/bitnami/redis/etc/replica.conf
      ARGS=("--port" "$${REDIS_PORT}")
      ARGS+=("--replicaof" "$${REDIS_MASTER_HOST}" "$${REDIS_MASTER_PORT_NUMBER}")
      ARGS+=("--protected-mode" "no")
      ARGS+=("--include" "/opt/bitnami/redis/etc/redis.conf")
      ARGS+=("--include" "/opt/bitnami/redis/etc/replica.conf")
      exec redis-server "$${ARGS[@]}"

      EOT
    }
    "kind" = "ConfigMap"
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
      "name" = "redis-scripts"
      "namespace" = "trivy-redis"
    }
  }
}

resource "kubernetes_manifest" "configmap_trivy" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "TRIVY_CACHE_BACKEND" = "redis://redis-master.trivy-redis.svc.cluster.local"
      "TRIVY_CACHE_DIR" = "/home/scanner/.cache/trivy"
      "TRIVY_DB_REPOSITORY" = "ghcr.io/aquasecurity/trivy-db"
      "TRIVY_DEBUG" = "true"
      "TRIVY_LISTEN" = "0.0.0.0:4954"
      "TRIVY_SKIP_DB_UPDATE" = "false"
    }
    "kind" = "ConfigMap"
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
  }
}