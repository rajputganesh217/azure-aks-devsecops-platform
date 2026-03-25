
resource_group_name = "aks-microservices-dev-rg"
location            = "eastus"

aks_name   = "microservices-aks"
dns_prefix = "microaks"

node_count = 1
vm_size    = "Standard_D2s_v3"

acr_name = "mydevopsacr123"
reports_storage_account_name = "devdevsecopsrep"

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
ssh_public_key      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/iisUGCVgM3oX8Y9fKpJ8/2gz+7HHkVMcb1RKtjRPcOojF6eFmF134erOf7swSvigI8RcZR4l8WJ/2LmrGJboXHqd+YcO8R/svXuJTP22RLVl2PdAyT9UFM0NFk+h7LH8Q5desyOeglSH9e+kGA6unGvn5atqAenyZ0NHxwFmbk562PYcVMH77+4a8R3D1Thw+e/D2fc2CXw8ETEETq6rZIWt0YR/ELdwN3qignZ862A3X5v/nA0PTIbdNcZdF+E2r2Uut7bO82nogvkeaSo3v4qQxx2Gh99EwZv5X1k/XFP/htUXB6B91AdMCfwlODUpiXLqUpT7/TIubEM+U32zAGethj++jfIB20yyEUmxZpjQxHQkChrZIXqeexYpyeFoqBi9uueauNFfGc7UTHSfmHrShEKdIiYwztWp3nG0TLW8oh0PSL8OJAHmYWjwjVYIReyRwLcO179g5Ydm5u4BndIH0dqnrSdqJT2andJ7gMi9ClXTqB67tH6MCMqtGBl6Whk2cUdUDZJE0JlovZ8+Xi6mkWH8mNva6ncXi2jFK6YB/NZXqgID7rcEbKfZVwZ+PcUQsvbNYLWjDTmoMQvMmU4BpBd0LQQZE0HU1dPudT6c6S0IvIXsb/vI/8YfRPo8UW+qsP8XCESidOMhNqTFlpir7r4D6v+OI0xs8Vmymw== admin@DELL"
