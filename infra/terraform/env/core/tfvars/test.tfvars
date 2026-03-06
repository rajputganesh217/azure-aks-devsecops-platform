
resource_group_name = "aks-microservices-test-rg"
location            = "canadacentral"

aks_name   = "microservices-aks-test"
dns_prefix = "microakstest"

node_count = 1
vm_size    = "Standard_D4s_v5"

acr_name = "mydevopsacrtest123"

environment = "test"
vnet_address_space = ["10.0.0.0/16"]
public_subnets = {
  "subnet-public-az1" = "10.0.1.0/24"
  "subnet-public-az2" = "10.0.2.0/24"
  "subnet-public-az3" = "10.0.3.0/24"
}
app_subnets = {
  "subnet-private-app-az1" = "10.0.10.0/24"
  "subnet-private-app-az2" = "10.0.11.0/24"
  "subnet-private-app-az3" = "10.0.12.0/24"
}
db_subnets = {
  "subnet-private-db-az1" = "10.0.20.0/24"
  "subnet-private-db-az2" = "10.0.21.0/24"
  "subnet-private-db-az3" = "10.0.22.0/24"
}
