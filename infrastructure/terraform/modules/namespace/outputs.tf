output "name" {
    description = "The created namespace name"
    value       = kubernetes_namespace_v1.this.metadata[0].name
}

output "labels" {
    description = "All labels applied to the namespace"
    value       = kubernetes_namespace_v1.this.metadata[0].labels
}