
resource_group_name = "aks-microservices-uat-rg"
location            = "eastus"

aks_name   = "microservices-aks-uat"
dns_prefix = "microaksuat"

node_count = 1
vm_size    = "Standard_B2s"

acr_name = "mydevopsacruat123"

environment        = "uat"
vnet_address_space = ["10.4.0.0/16"]
public_subnets = {
  "subnet-public-az1" = "10.4.1.0/24"
  "subnet-public-az2" = "10.4.2.0/24"
  "subnet-public-az3" = "10.4.3.0/24"
}
app_subnets = {
  "subnet-private-app-az1" = "10.4.10.0/24"
  "subnet-private-app-az2" = "10.4.11.0/24"
  "subnet-private-app-az3" = "10.4.12.0/24"
}
db_subnets = {
  "subnet-private-db-az1" = "10.4.20.0/24"
  "subnet-private-db-az2" = "10.4.21.0/24"
  "subnet-private-db-az3" = "10.4.22.0/24"
}
