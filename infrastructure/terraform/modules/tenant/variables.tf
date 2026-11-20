variable "team" {
  description = "Team or tenant identifier (e.g., payments, orders)"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "cpu_limit" {
  description = "Total CPU limit for the tenant namespace"
  type        = string
  default     = "1"
}

variable "memory_limit" {
  description = "Total memory limit for the tenant namespace"
  type        = string
  default     = "1Gi"
}

variable "pod_limit" {
  description = "Maximum number of pods allowed in the tenant namespace"
  type        = string
  default     = "10"
}