variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure Region"
  type        = string
}

variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
  default     = "devsecops-vnet"
}

variable "vnet_address_space" {
  description = "Address space for the VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "public_subnets" {
  description = "Map of public subnets (name => prefix)"
  type        = map(string)
  default = {
    "subnet-public-az1" = "10.0.1.0/24"
    "subnet-public-az2" = "10.0.2.0/24"
    "subnet-public-az3" = "10.0.3.0/24"
  }
}

variable "app_subnets" {
  description = "Map of private app subnets (name => prefix)"
  type        = map(string)
  default = {
    "subnet-private-app-az1" = "10.0.10.0/24"
    "subnet-private-app-az2" = "10.0.11.0/24"
    "subnet-private-app-az3" = "10.0.12.0/24"
  }
}

variable "db_subnets" {
  description = "Map of private db subnets (name => prefix)"
  type        = map(string)
  default = {
    "subnet-private-db-az1" = "10.0.20.0/24"
    "subnet-private-db-az2" = "10.0.21.0/24"
    "subnet-private-db-az3" = "10.0.22.0/24"
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
