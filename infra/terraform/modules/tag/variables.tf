variable "environment" {
  type        = string
  description = "The target deployment environment (e.g., dev, qa, prod)"
}

variable "project" {
  type        = string
  description = "The name of the project"
  default     = "azure-aks-devsecops-platform"
}

variable "owner" {
  type        = string
  description = "The owner of the resources"
  default     = "devsecops_team"
}

variable "cost_center" {
  type        = string
  description = "The cost center for billing"
  default     = "CC1001"
}
