
resource_group_name = "aks-microservices-rg"
location            = "canadacentral"

aks_name   = "microservices-aks"
dns_prefix = "microaks"

node_count = 1
vm_size    = "Standard_D4s_v5"

acr_name = "mydevopsacr123"

environment        = "dev"
vnet_address_space = ["10.1.0.0/16"]
public_subnets = {
  "subnet-public-az1" = "10.1.1.0/24"
  "subnet-public-az2" = "10.1.2.0/24"
  "subnet-public-az3" = "10.1.3.0/24"
}
app_subnets = {
  "subnet-private-app-az1" = "10.1.10.0/24"
  "subnet-private-app-az2" = "10.1.11.0/24"
  "subnet-private-app-az3" = "10.1.12.0/24"
}
db_subnets = {
  "subnet-private-db-az1" = "10.1.20.0/24"
  "subnet-private-db-az2" = "10.1.21.0/24"
  "subnet-private-db-az3" = "10.1.22.0/24"
}
