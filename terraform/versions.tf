terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "2.11.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.23.0"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}