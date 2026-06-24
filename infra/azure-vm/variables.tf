variable "environment" {
  type        = string
  description = "Deployment environment (dev, prod)"
  default     = "dev"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "eastus"
}

variable "project_name" {
  type        = string
  description = "Project name used in resource naming"
  default     = "incident-commander"
}

variable "resource_group_name" {
  type        = string
  description = "Existing resource group name. If empty, a new RG is created"
  default     = ""
}

variable "vm_size" {
  type        = string
  description = "Azure VM size"
  default     = "Standard_B1s"
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VM"
  default     = "azureuser"
}

variable "admin_password" {
  type        = string
  description = "Admin password for the VM"
  sensitive   = true
}
