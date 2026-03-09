variable "aks_name" {}
variable "location" {}
variable "resource_group_name" {}
variable "dns_prefix" {}
variable "node_count" {}
variable "vm_size" {}
variable "log_analytics_workspace_id" {
  type = string
}

variable "vnet_subnet_id" {
  description = "The Subnet ID to deploy the AKS nodes and pods into"
  type        = string
}
variable "ingress_application_gateway_id" {
  description = "Application Gateway ID for AGIC"
  type        = string
  default     = null
}