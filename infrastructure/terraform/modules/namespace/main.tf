terraform {
    required_providers {
        kubernetes = {
            source  = "hashicorp/kubernetes"
            version = "~> 2.35"
        }
    }
}

locals {
    standard_labels = {
        managed-by  = "terraform"
        environment = var.environment
        team        = var.team
    }
}

resource "kubernetes_namespace_v1" "this" {
    metadata {
        name   = var.name
        labels = merge(local.standard_labels, var.extra_labels)
    }
}

resource "kubernetes_resource_quota_v1" "this" {
    count = var.enable_quota ? 1 : 0

    metadata {
        name      = "${var.name}-quota"
        namespace = kubernetes_namespace_v1.this.metadata[0].name
    }

    spec {
        hard = {
            "limits.cpu"    = var.cpu_limit
            "limits.memory" = var.memory_limit
        }
    }
}

resource "kubernetes_limit_range_v1" "this" {
  count = var.enable_quota ? 1 : 0

  metadata {
    name      = "${var.name}-limits"
    namespace = kubernetes_namespace_v1.this.metadata.name
  }

  spec {
    limit {
      type = "Container"
      default = {
        cpu    = "250m"
        memory = "256Mi"
      }
      default_request = {
        cpu    = "50m"
        memory = "64Mi"
      }
    }
  }
}