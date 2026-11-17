module "namespaces" {
    source   = "./modules/namespace"
    for_each = var.namespaces

    name         = each.key
    environment  = each.value.environment
    team         = each.value.team
    enable_quota = each.value.enable_quota
    cpu_limit    = each.value.cpu_limit
    memory_limit = each.value.memory_limit
    extra_labels = each.value.extra_labels
}

module "dev_rbac" {
  source = "./modules/rbac"

  namespace            = module.namespaces["tf-dev"].name
  service_account_name = "dev-app-sa"
}

resource "kubernetes_secret_v1" "db_credentials" {
  metadata {
    name      = "db-credentials"
    namespace = module.namespaces["tf-dev"].name
  }

  data = {
    DB_USER = "app_user"
    DB_PASS = var.app_db_password
  }

  type = "Opaque"
}

module "tenants" {
  source   = "./modules/tenant"
  for_each = var.tenants

  team         = each.value.team
  environment  = each.value.environment
  cpu_limit    = each.value.cpu_limit
  memory_limit = each.value.memory_limit
  pod_limit    = each.value.pod_limit
}