variable "resource_group" {
  description = "The name of the resource group"
  type        = string
  default     = "rsg-dev123"
}

variable "location" {
  description = "default location"
  type        = string
  default     = "canadacentral"
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
  default     = "vnet-dev"
}

variable "vnet_address_space" {
  description = "The address space of the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
  default     = "subnet-dev"
}
variable "subnet_address_prefix" {
  description = "The address prefix of the subnet"
  type        = string
  default     = "10.0.1.0/24"
}
variable "network_security_group_name" {
  description = "The name of the network security group"
  type        = string
  default     = "nsg-dev"
}
variable "network_security_rule_name" {
  description = "The name of the network security rule"
  type        = string
  default     = "rdp-rule-dev"
}
variable "network_security_rule_priority" {
  description = "The priority of the network security rule"
  type        = number
  default     = 1000
}
variable "public_ip_name" {
  description = "The name of the public IP"
  type        = string
  default     = "pip-dev"
}
variable "admin_username" {
  description = "The admin username"
  type        = string
  default     = "adminuser"
}
variable "admin_password" {
  description = "The admin password"
  type        = string
  default     = "Admin@123"
}
