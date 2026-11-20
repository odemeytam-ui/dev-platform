output "provisioned_namespaces" {
  description = "Summary of all namespaces created by Terraform"
  value = {
    for k, mod in module.namespaces : k => {
      name   = mod.name
      labels = mod.labels
    }
  }
}

output "dev_service_account" {
  description = "ServiceAccount created in tf-dev"
  value       = module.dev_rbac.service_account_name
}

output "secret_name" {
  description = "Name of the managed Kubernetes Secret"
  value       = kubernetes_secret_v1.db_credentials.metadata[0].name
}

output "db_password_check" {
  description = "Demonstrates Terraform redacting sensitive outputs in CLI"
  value       = var.app_db_password
  sensitive   = true
}

output "provisioned_tenants" {
  description = "All active tenant namespaces and ServiceAccounts"
  value = {
    for k, mod in module.tenants : k => {
      namespace       = mod.namespace
      service_account = mod.service_account
    }
  }
}