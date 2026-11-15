variable "name" {
    description = "Name of the kubernetes namespace"
    type        = string
}

variable "environment" {
    description = "Environment tag (e.g., dev, staging, prod)"
    type        = string
}

variable "team" {
    description = "owning team label"
    type        = string
    default     = "platform"
}

variable "extra_labels" {
    description = "Additional custom labels to merge onto the namespace"
    type        = map(string)
    default     = {}
}

variable "enable_quota" {
    description = "Whether to attach a default ResourceQuota to this namespace"
    type        = bool
    default     = false
}

variable "cpu_limit" {
    description = "Total CPU limit across all pods in the namespace"
    type        = string
    default     = "1"
}

variable "memory_limit" {
    description = "Total memory limit across all pods in the namespace"
    type        = string
    default     = "1Gi"
}