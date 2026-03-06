############################################
# Azure Authentication (Jenkins will pass)
############################################

variable "subscription_id" {
  type      = string
  sensitive = true
}

variable "tenant_id" {
  type      = string
  sensitive = true
}

variable "client_id" {
  type      = string
  sensitive = true
}

variable "client_secret" {
  type      = string
  sensitive = true
}

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
}
