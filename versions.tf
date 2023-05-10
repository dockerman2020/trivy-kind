terraform {
  required_providers {

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.18.1"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }

  }
  required_version = ">= 1.0.0"
}