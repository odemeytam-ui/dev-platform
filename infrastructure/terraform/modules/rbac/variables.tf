variable "namespace" {
  description = "Namespace where the ServiceAccount and Role will live"
  type        = string
}

variable "service_account_name" {
  description = "Name of the ServiceAccount"
  type        = string
}

variable "allowed_resources" {
  description = "Kubernetes core resources this role can read"
  type        = list(string)
  default     = ["pods", "services", "configmaps"]
}