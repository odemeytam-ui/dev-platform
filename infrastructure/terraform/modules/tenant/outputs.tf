output "namespace" {
  value = kubernetes_namespace_v1.tenant.metadata[0].name
}

output "service_account" {
  value = kubernetes_service_account_v1.team_sa.metadata[0].name
}