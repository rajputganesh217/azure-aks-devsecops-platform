subscription_id = ""
tenant_id       = ""
client_id       = ""
client_secret   = ""

resource_group_name = "aks-microservices-qa-rg"
location            = "canadacentral"

aks_name   = "microservices-aks-qa"
dns_prefix = "microaksqa"

node_count = 2
vm_size    = "Standard_DS2_v2"

acr_name = "mydevopsacrqa123"

environment = "qa"
vnet_address_space = ["10.2.0.0/16"]
public_subnets = {
  "subnet-public-az1" = "10.2.1.0/24"
  "subnet-public-az2" = "10.2.2.0/24"
  "subnet-public-az3" = "10.2.3.0/24"
}
app_subnets = {
  "subnet-private-app-az1" = "10.2.10.0/24"
  "subnet-private-app-az2" = "10.2.11.0/24"
  "subnet-private-app-az3" = "10.2.12.0/24"
}
db_subnets = {
  "subnet-private-db-az1" = "10.2.20.0/24"
  "subnet-private-db-az2" = "10.2.21.0/24"
  "subnet-private-db-az3" = "10.2.22.0/24"
}
