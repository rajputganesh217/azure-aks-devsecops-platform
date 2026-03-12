############################################
# Jump Server VM (Bastion for private AKS)
############################################

data "azurerm_public_ip" "jump" {
  name                = "${var.name}-pip"
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_group" "jump" {
  name                = "${var.name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

resource "azurerm_network_interface" "jump" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = data.azurerm_public_ip.jump.id
  }

  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "jump" {
  network_interface_id      = azurerm_network_interface.jump.id
  network_security_group_id = azurerm_network_security_group.jump.id
}

resource "azurerm_linux_virtual_machine" "jump" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [azurerm_network_interface.jump.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  custom_data = base64encode(local.user_data)

  tags = var.tags
}

locals {
  user_data = <<-USERDATA
#!/bin/bash
set -e
exec > /var/log/jump-setup.log 2>&1
export DEBIAN_FRONTEND=noninteractive

echo "=== Updating system ==="
apt-get update -y
apt-get install -y ca-certificates curl apt-transport-https gnupg jq

echo "=== Installing Azure CLI ==="
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

echo "=== Installing kubectl and kubelogin with retries ==="
n=0
while [ $n -lt 5 ]; do
  if az aks install-cli; then
    echo "CLI tools installed successfully"
    break
  fi
  n=$((n+1))
  echo "CLI install failed, retrying in 10s..."
  sleep 10
done

echo "=== Installing Docker ==="
apt-get install -y docker.io
systemctl enable docker
systemctl start docker
usermod -aG docker ${var.admin_username}

echo "=== Installing Helm ==="
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "=== Setting up kubeconfig (with retry for role propagation) ==="
n=0
while [ $n -lt 30 ]; do
  if su - ${var.admin_username} -c "az login --identity" && \
     su - ${var.admin_username} -c "az aks get-credentials --resource-group ${var.resource_group_name} --name ${var.aks_name} --admin --overwrite-existing"; then
    echo "Kubeconfig configured successfully on attempt $((n+1))"
    break
  fi
  n=$((n+1))
  echo "Attempt $n failed, retrying in 20s..."
  sleep 20
done

echo "=== Logging into ACR ==="
su - ${var.admin_username} -c "az acr login --name ${var.acr_name}" || true

echo "=== Jump server setup complete! ==="
USERDATA
}
