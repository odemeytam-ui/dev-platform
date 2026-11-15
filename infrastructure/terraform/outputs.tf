output "provisioned_namespaces" {
    description = "Summary of all namespaces created by Terraform"
    value = {
        for k, mod in module.namespaces : k => {
            name   = mod.name
            labels = mod.labels
        }
    }
}