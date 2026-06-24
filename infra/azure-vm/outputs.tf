output "resource_group_name" {
  description = "Resource group name"
  value       = local.rg_name
}

output "vm_name" {
  description = "Virtual machine name"
  value       = azurerm_linux_virtual_machine.this.name
}

output "public_ip" {
  description = "Public IP address of the VM"
  value       = azurerm_public_ip.this.ip_address
}

output "admin_username" {
  description = "Admin username"
  value       = var.admin_username
}
