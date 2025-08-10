# Description: Defines the virtual machines and their associated network interfaces.

# --- Bastion Host VM in Public Subnet ---

# Creates a network interface for the Bastion Host.
resource "azurerm_network_interface" "bastion_nic" {
  name                = "bastion-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.public_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion_pip.id
  }
}

# Creates the Bastion Host (Jump Box) virtual machine.
resource "azurerm_linux_virtual_machine" "bastion_vm" {
  name                = "BastionVM"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s" # Free tier eligible
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.bastion_nic.id,
  ]

  # Configures SSH access using the public key.
  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}


# --- Application VM in Private Subnet ---

# Creates a network interface for the Application Server.
resource "azurerm_network_interface" "app_nic" {
  name                = "app-server-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.private_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Reads the content of the shell script to be used as user_data.
data "local_file" "docker_script" {
  filename = "${path.module}/install_docker.sh"
}

# Creates the Application Server virtual machine.
resource "azurerm_linux_virtual_machine" "app_vm" {
  name                = "AppServerVM"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s" # Free tier eligible
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.app_nic.id,
  ]

  # The startup script is base64 encoded and passed to the VM.
  # It will run automatically on the first boot.
  custom_data = base64encode(data.local_file.docker_script.content)

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  
  # Ensures the bastion VM is created before this one.
  depends_on = [ azurerm_linux_virtual_machine.bastion_vm ]
}
