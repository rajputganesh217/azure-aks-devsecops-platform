variable "resource_group_name" {
  type        = string
  description = "Name of the persistent resource group"
  default     = "aks-microservices-dev-rg"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "acr_name" {
  type        = string
  description = "Name of the shared ACR (globally unique)"
  default     = "mydevopsacr123"
}

variable "tfstate_storage_account_name" {
  type        = string
  description = "Storage account for Terraform state"
  default     = "tfstatedevsecops01"
}

variable "reports_storage_account_name" {
  type        = string
  description = "Storage account for security reports"
  default     = "devdevsecopsrep"
}
