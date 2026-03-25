
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
ssh_public_key      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCapleT9dhPEdA+FeaxRJ4518k41pHveroSSr7aIBosniFKxe//N8iBgcJPn2nPzEQDG6iK+1b5Zn0L4uxeENsqml/5Z5kcacooWd2NKV0UflVYTvM2lYkz45azOlIX6xriLOUYdDIox1DuOUjkeGtlQ1bG+eaVWbVLiY2qdMRUm8E39fRc1IP8AnBCvQJ/g8iuWk4NHKi9VoS50uRKOcn62wuE96aiKlS/x+O7jcudpXAwsHHyI13BwEhJUjYhim/FhV6eM0ubu3d8EKIjykr/9RETT/Ss4Xb44c9eVbCXZtDANLK5EOq/fXJMwE78jduEa28BaDMPu1mkuC2RxsPu5CzHeexA1r8MVPFZrUwPhBP2NLyDQMh0MXYALuHYLlcDCDI2/7hxlokoV1Aco8ns9DKCQxLoIYw7zEdEXcurwPQjYCHyc/NLvBQwvTyLcdO3DY9bE4a19HUht+1dKqtHZS97Qk3Fj9DvN3RN9CyyfsEOW7i2KAWbWVqNc/Eptyfk30zF36qjCtnbHZ5w5bReNOEDTc16o7K2vd/R47IPGG5lfdF6hjS3CrtuqxXO2zEciiGB9X+9yXTS6lGXO0EFXhcm6EfuuR8MdGwdWoyq4yCw3csJ3NZFITB5EecNl25/E1f+cWajn7aIpf0Ua149zcwpQ5z0m+kE+EM2qHRtbQ== admin@DELL"
