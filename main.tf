resource "azurerm_resource_group" "rsg" {
  name     = var.resource_group
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  depends_on          = [azurerm_resource_group.rsg]
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group
}

resource "azurerm_subnet" "subnet" {
  depends_on           = [azurerm_virtual_network.vnet]
  name                 = var.subnet_name
  resource_group_name  = var.resource_group
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.subnet_address_prefix]
}



resource "azurerm_public_ip" "pip" {
  depends_on          = [azurerm_resource_group.rsg]
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rsg.name
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "nsg" {
  depends_on          = [azurerm_resource_group.rsg]
  name                = var.network_security_group_name
  location            = var.location
  resource_group_name = var.resource_group
}



resource "azurerm_network_security_rule" "rdp" {
  depends_on                  = [azurerm_network_security_group.nsg]
  name                        = var.network_security_rule_name
  resource_group_name         = var.resource_group
  priority                    = var.network_security_rule_priority
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = var.network_security_group_name
}

resource "azurerm_network_security_rule" "ssh" {
  depends_on                  = [azurerm_network_security_group.nsg]
  name                        = "sshport"
  resource_group_name         = var.resource_group
  priority                    = 1010
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = var.network_security_group_name
}



resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-dev"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "ipcofig-dev"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  depends_on          = [azurerm_network_interface.nic]
  name                = "vm-dev"
  resource_group_name = var.resource_group
  location            = var.location
  size                = "Standard_B2s"
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  disable_password_authentication = false

  # admin_ssh_key {
  #   username   = var.vm.admin_username
  #   public_key = file(var.ssh_public_key_path)
  # }


  source_image_reference {

    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
  network_interface_ids = [
    azurerm_network_interface.nic.id

  ]

  os_disk {
    name                 = "osdisk-dev"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

}
