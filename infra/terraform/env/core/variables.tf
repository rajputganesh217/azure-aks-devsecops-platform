

############################################
# Infrastructure Configuration
############################################

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

############################################
# AKS Configuration
############################################

variable "aks_name" {
  type = string
}

variable "dns_prefix" {
  type = string
}

variable "aks_vnet_subnet_id" {
  type    = string
  default = ""
}

variable "node_count" {
  type = number
}

variable "vm_size" {
  type = string
}

############################################
# Container Registry
############################################

variable "acr_name" {
  type = string
}
############################################
# Application Secrets (Coming from Jenkins)
############################################

variable "postgres_db" {
  type      = string
  sensitive = true
}

variable "postgres_user" {
  type      = string
  sensitive = true
}

variable "postgres_password" {
  type      = string
  sensitive = true
}

variable "db_host" {
  type      = string
  sensitive = true
  default   = "postgres.default.svc.cluster.local"
}

variable "commit_id" {
  type        = string
  description = "Commit ID for tagging or tracking"
  default     = ""
}

############################################
# Dynamic Environment Variables
############################################

variable "environment" {
  description = "The target environment (e.g., dev, qa, test, prod)"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the VNet"
  type        = list(string)
}

variable "public_subnets" {
  description = "Map of public subnets (name => prefix)"
  type        = map(string)
}

variable "app_subnets" {
  description = "Map of private app subnets (name => prefix)"
  type        = map(string)
}

variable "db_subnets" {
  description = "Map of private db subnets (name => prefix)"
  type        = map(string)
}

variable "project" {
  type    = string
  default = "devsecops-platform"
}

variable "owner" {
  type    = string
  default = "cloud-team"
}

variable "cost_center" {
  type    = string
  default = "CC1001"
}


