terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

# Generate a unique random password per tenant (stored only in Terraform state & K8s Secret, never in Git)
resource "random_password" "db_password" {
  length  = 24
  special = false
}

# Create the Kubernetes Secret expected by the Helm chart (existingSecret: "sample-app-db-secret")
resource "kubernetes_secret_v1" "db_secret" {
  metadata {
    name      = "sample-app-db-secret"
    namespace = kubernetes_namespace_v1.tenant.metadata[0].name
  }

  data = {
    POSTGRES_DB       = "appdb"
    POSTGRES_USER     = "appuser"
    POSTGRES_PASSWORD = random_password.db_password.result
  }

  type = "Opaque"
}

locals {
  namespace_name = "tenant-${var.team}-${var.environment}"
  labels = {
    managed-by  = "terraform"
    tenant      = var.team
    environment = var.environment
    tier        = "tenant"
  }
}

# 1. Tenant Namespace
resource "kubernetes_namespace_v1" "tenant" {
  metadata {
    name   = local.namespace_name
    labels = local.labels
  }
}

# 2. ResourceQuota
resource "kubernetes_resource_quota_v1" "quota" {
  metadata {
    name      = "${local.namespace_name}-quota"
    namespace = kubernetes_namespace_v1.tenant.metadata[0].name
  }

  spec {
    hard = {
      "limits.cpu"    = var.cpu_limit
      "limits.memory" = var.memory_limit
      "pods"          = var.pod_limit
    }
  }
}

# 3. LimitRange (Default container sizing)
resource "kubernetes_limit_range_v1" "limits" {
  metadata {
    name      = "${local.namespace_name}-limits"
    namespace = kubernetes_namespace_v1.tenant.metadata[0].name
  }

  spec {
    limit {
      type = "Container"
      default = {
        cpu    = "200m"
        memory = "256Mi"
      }
      default_request = {
        cpu    = "50m"
        memory = "64Mi"
      }
    }
  }
}

# 4. Team ServiceAccount & Namespace-Scoped RBAC
resource "kubernetes_service_account_v1" "team_sa" {
  metadata {
    name      = "${var.team}-sa"
    namespace = kubernetes_namespace_v1.tenant.metadata[0].name
  }
}

resource "kubernetes_role_v1" "team_admin" {
  metadata {
    name      = "${var.team}-namespace-role"
    namespace = kubernetes_namespace_v1.tenant.metadata[0].name
  }

  rule {
    api_groups = ["", "apps", "networking.k8s.io"]
    resources  = ["pods", "services", "configmaps", "secrets", "deployments", "replicasets", "ingresses", "persistentvolumeclaims"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

resource "kubernetes_role_binding_v1" "team_binding" {
  metadata {
    name      = "${var.team}-namespace-binding"
    namespace = kubernetes_namespace_v1.tenant.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.team_admin.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.team_sa.metadata[0].name
    namespace = kubernetes_namespace_v1.tenant.metadata[0].name
  }
}

# 5. NetworkPolicy: Isolate tenant ingress (allow only same-namespace + Traefik Ingress controller)
resource "kubernetes_network_policy_v1" "tenant_isolation" {
  metadata {
    name      = "tenant-isolation-policy"
    namespace = kubernetes_namespace_v1.tenant.metadata[0].name
  }

  spec {
    pod_selector {} # Applies to ALL pods in this tenant namespace

    policy_types = ["Ingress"]

    ingress {
      # Allow traffic from pods within the SAME tenant namespace
      from {
        pod_selector {}
      }
      # Allow traffic from Traefik Ingress controller in kube-system
      from {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = "kube-system"
          }
        }
      }
    }
  }
}