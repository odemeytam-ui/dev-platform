kube_context = "k3d-dev-platform-cluster"

namespaces = {
    "tf-dev" = {
        environment  = "development"
        team         = "backend"
        enable_quota = true
        cpu_limit    = "1"
        memory_limit = "1Gi"
        extra_labels = {
            tier = "app"
        }
    }

    "tf-staging" = {
        environment  = "staging"
        team         = "backend"
        enable_quota = true
        cpu_limit    = "2"
        memory_limit = "2Gi"
    }

    "tf-monitoring" = {
        environment  = "shared"
        team         = "platform"
        enable_quota = false
    }
}

tenants = {
  "payments-dev" = {
    team         = "payments"
    environment  = "dev"
    cpu_limit    = "1"
    memory_limit = "1Gi"
    pod_limit    = "10"
  }
  "orders-dev" = {
    team         = "orders"
    environment  = "dev"
    cpu_limit    = "1"
    memory_limit = "1Gi"
    pod_limit    = "10"
  }
}