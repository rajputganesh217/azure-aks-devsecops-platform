variable "name" {
  description = "Name of the jump server VM"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the jump server NIC"
  type        = string
}

variable "vm_size" {
  description = "VM size for the jump server"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "admin_username" {
  description = "Admin username for SSH"
  type        = string
  default     = "ganesh"
}

variable "ssh_public_key" {
  description = "SSH public key for authentication"
  type        = string
}

variable "aks_name" {
  description = "AKS cluster name (for kubeconfig setup)"
  type        = string
}

variable "acr_name" {
  description = "ACR name (for docker login)"
  type        = string
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
