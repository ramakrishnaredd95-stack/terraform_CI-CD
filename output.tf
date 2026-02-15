output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.rsg.name
}

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = azurerm_resource_group.rsg.id
}

output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}

output "virtual_network_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = azurerm_subnet.subnet.name
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = azurerm_subnet.subnet.id
}