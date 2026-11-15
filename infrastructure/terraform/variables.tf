variable "kubeconfig_path" {
    description = "Path to kubeconfig file"
    type        = string
    default     = "~/.kube/config"
}

variable "kube_context" {
    description = "Kubernetes context to target"
    type        = string
    default     = "k3d-dev-platform-cluster"
}

variable "namespaces" {
    description = "Map of namespaces to provision"
    type        = map(object({
        environment  = string
        team         = string
        enable_quota = optional(bool, false)
        cpu_limit    = optional(string, "1")
        memory_limit = optional(string, "1Gi")
        extra_labels = optional(map(string, {}))
    }))
}