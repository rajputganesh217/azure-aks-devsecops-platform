
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
ssh_public_key      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCjrmfpwHRqq9ZlioQIKo8KA0k+wl4qgjWW+jOIE8j59iU47NDZSZfZIYYPkpgvpg8n8h3xYk6GB0RPuB/P9qgDj6na36LM/EBV7zboZE1rm/u5VCAOUPLyFXu3mk8ho2c9JbkMhx5tbExLSQVct4Iv4j1dL5zsuKR9oM1n4IfagGJuVzlCDtCarS5xgUhq8vdFbKrTJykGgNXIGpIf+X47d+1Hcl4uNKNC0P8wxrh9SgEhnrmf6AkZg/IDq2ZGny9b40wP6ZxSHTKhJEp39ueZ54DVYaLA1uLDxv5/GRLSdG6C836fNJiSWik+vvin+oYfskFXyV7KY8NPMIYjVH85rqK6vF8bIEOJenp7g30WWRbwYLQjkYdgEqbPJOgm5I8sJTj85u0TMoW/TDxjX6ZQdM3AunFqMTiBiSGZs2lcEAtz4sxaGYQe3SW6GuYvCkV+FNFlu6AldUdLaE1iBkwQUz4kMUSdJiaQYLtpC4gQQr85Qdd+Q6Mi/uTogr5W2BTSnk4XqqHIBaD5mr3v6iPLSKrm8PmFuxxd/fXft8lWIdwlT8kI+GT4GvAcaIkhBp+Cue32y1nig5b3wMT1afdjxlLKBin7raEAOWD8pxBphXfIRxPlJgDPP30pXiSiKCFg8yquRn7qT6HF+zwSEcOWh645l+d5LaQ/o8bPwcQQSQ== ganesh-jump"
