
resource_group_name = "aks-microservices-uat-rg"
location            = "eastus"

aks_name   = "microservices-aks-uat"
dns_prefix = "microaksuat"

node_count = 1
vm_size             = "Standard_D2s_v3"
jump_server_vm_size = "Standard_D2s_v3"

acr_name = "mydevopsacr123"
reports_storage_account_name = "devdevsecopsrep"

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

jump_admin_username = "ganesh"
ssh_public_key      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCnoZ8EII260/7gdXZsldt1XBzU2C6dwcKTdvDVTzTtqkcQdrz0v8vUebA5UZSGutOD/72jWxvKFkSxSoixsvlGQ/KCX/auObeRUG0fyqdSENqWdo0JpXNwNT3cWNHC2uhDWsDRhwAuWFh7TDwSlRSeZfKZqWchx1AJPOSzZwOLjX3DJIt2zCjguj6aY7kRWxhu22hsP7mnPn4Gcpp4hNJLNxykhjeCE0WZL8ej9tqMNcfo8Y84lVcVdF4H20qx6XeLaJX193PxzjHXaPLGPcsXqOSk7Fo1f7mv3lu7W+hvUUJVh20i/K+IcvDb8hT2D8/6E7q1507CKMsy+K+w7uV0oatwegRaqlnbm3nRbw1/v5d9fK7n3wWdG61s5mWz/ohGnl8/VhbhDqyTJ01o+Gjflcfsm45lt3HbzeQD9D8w03yIOL+a8asV7plby0jGNFLD8pzHTjAOgwvtsQTyXRRPhxmXpGgXzID0dAS/soIK4JOKMDgqEVeceuyt+/5XsU+gpca0N4Sgzf6zPLIosisC2nZFdwm+IApYlsW3ZysRNiOWVcF0C/W++MEVWuPZenMBVw3fP/ZVpN5VB42BhfVImSekLkqlh7U3nq8iReeSFKN+7T6+WKn4B6tJZilf/bT9SD2TmPQz9gSTXvXX+insNFCpMP2xnZVviFZgvCN3CQ== admin@DELL"
