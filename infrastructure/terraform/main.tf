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