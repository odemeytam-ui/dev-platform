output "service_account_name" {
  value = kubernetes_service_account_v1.this.metadata.name
}

output "role_name" {
  value = kubernetes_role_v1.reader.metadata.name
}