# Description: Defines all networking resources for the application.
# This includes the VNet, subnets, public IP, and Network Security Groups (NSGs).

# Creates the main Virtual Network (VNet) for the application.
resource "azurerm_virtual_network" "vnet" {
  name                = "app-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# --- Public Subnet Resources (for the Bastion Host) ---

# Creates the public-facing subnet.
resource "azurerm_subnet" "public_subnet" {
  name                 = "public-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Allocates a static public IP address for the Bastion Host.
resource "azurerm_public_ip" "bastion_pip" {
  name                = "bastion-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Creates a Network Security Group (firewall) for the public subnet.
resource "azurerm_network_security_group" "public_nsg" {
  name                = "public-subnet-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Security rule to allow incoming SSH traffic from the internet.
  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

# Associates the public NSG with the public subnet.
resource "azurerm_subnet_network_security_group_association" "public_nsg_assoc" {
  subnet_id                 = azurerm_subnet.public_subnet.id
  network_security_group_id = azurerm_network_security_group.public_nsg.id
}


# --- Private Subnet Resources (for the Application Server) ---

# Creates the private, internal-only subnet.
resource "azurerm_subnet" "private_subnet" {
  name                 = "private-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Creates a Network Security Group (firewall) for the private subnet.
resource "azurerm_network_security_group" "private_nsg" {
  name                = "private-subnet-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Security rule to allow SSH traffic ONLY from the public subnet's address range.
  security_rule {
    name                       = "AllowSSHFromPublicSubnet"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = azurerm_subnet.public_subnet.address_prefixes[0]
    destination_address_prefix = "*"
  }

  # Security rule to allow HTTP traffic ONLY from the public subnet for testing the web server.
  security_rule {
    name                       = "AllowHTTPFromPublicSubnet"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = azurerm_subnet.public_subnet.address_prefixes[0]
    destination_address_prefix = "*"
  }
}

# Associates the private NSG with the private subnet.
resource "azurerm_subnet_network_security_group_association" "private_nsg_assoc" {
  subnet_id                 = azurerm_subnet.private_subnet.id
  network_security_group_id = azurerm_network_security_group.private_nsg.id
}
