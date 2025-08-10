# Description: Defines input variables for the Terraform configuration.
# This allows for easy customization of resource names, locations, and credentials.

variable "resource_group_name" {
  description = "The name of the resource group where all resources will be created."
  type        = string
  default     = "TerraformDockerRG"
}

variable "location" {
  description = "The Azure region where the resources will be deployed."
  type        = string
  default     = "East US"
}

variable "admin_username" {
  description = "The administrator username for the virtual machines."
  type        = string
  default     = "azureuser"
}

variable "ssh_key_path" {
  description = "The file path to the public SSH key used for VM authentication."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}
