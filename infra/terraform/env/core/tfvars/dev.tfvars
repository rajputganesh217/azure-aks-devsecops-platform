
resource_group_name = "aks-microservices-dev-rg"
location            = "eastus"

aks_name   = "microservices-aks"
dns_prefix = "microaks"

node_count = 1
vm_size    = "Standard_D2s_v3"

acr_name = "mydevopsacr123"

environment        = "dev"
vnet_address_space = ["10.1.0.0/16"]

aks_vnet_subnet_id = ""
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

jump_server_vm_size = "Standard_D2s_v3"
jump_admin_username = "ganesh"
ssh_public_key      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDyUdlGKL6J/H4DJ9gLhV2a8PPnxKBduUT90GkTTZV8q6gFPMvAgmX7iepYiTfhT3GvSLQvmBV1LCVRPIHeAG4poniAT/+UqmvlkbHBoMbkkbaO82Zg3FgyVcXfGraparAQkdeSS4cwgf0s+lZBlSDuz7l6HHhpuP6ihdETxW3I+81Kw/E1r63CINniK2k7FECYZyIPzTHhJxPyPvjdmmgYrE9J1iOjT2PkjhJmlpYlt8D1bDcVBE9jytpxP72KtMezWPNvODbs1cv0FHCpDstdGjBM4L2s7SQyCwuNcl+WlxbswDYLY/HPOB61JoaHX7xoDNotMn0ZRBWAzU5FNhEt86da8BDe/4JW2YMc3IGISwSX9uSw/7kBMxh/Kg5Zkz/8X5M6komYlNs+lbN03Ogt2V/iFswHdtToDGRg5mJ2dcZQtADuARzqRByCedJLab1oqTsD6uD9njIFy9hxiMMwJPti1M8gPAeNsHzl+56UPAIOd8g5E9RtuLI+SzJCnJ7WhsUbqWj53+4HzpfW3a5RrjJZb4548pp6yTvb2hW6Ps70NGD/GaXDB7wWHrs8BgqeXsVuTSW+9QqNvOUWDsmkn7jqxMJShU3RjKsXbkWsucRO3oId+vDILC5G9j8i60LqDw4cWqCNX34f+CYGKj9KHfQyg0V6tSCjbxyA/nk0lw== admin@DELL"
