variable "resource_group_location" {
  default     = "centralindia"
  description = "Location of the resource group."
}

variable "rg" {
  type        = string
  default     = "rg-avd-compute"
  description = "Name of the Resource group in which to deploy session host"
}

variable "rdsh_count" {
  description = "Number of AVD machines to deploy"
  default     = 1
}

variable "prefix" {
  type        = string
  default     = "avdtf"
  description = "Prefix of the name of the AVD machine(s)"
}

variable "domain_name" {
  type        = string
  default     = "amalcloud.xyz"
  description = "Name of the domain to join"
}

variable "domain_user_upn" {
  type        = string
  default     = "amal.abraham" # do not include domain name as this is appended
  description = "Username for domain join (do not include domain name as this is appended)"
}

variable "domain_password" {
  type        = string
  default     = "Cloud@Builder"
  description = "Password of the user to authenticate with the domain"
  sensitive   = true
}

variable "vm_size" {
  description = "Size of the machine to deploy"
  default     = "Standard_DS2_v5"
}

variable "subnet" {
  description = "subnet details"
  default = "/subscriptions/2e824d6b-6dc7-41e5-b887-f6a88f67fb61/resourceGroups/RG_Compute/providers/Microsoft.Network/virtualNetworks/RG_Compute-vnet/subnets/default"
  
}

variable "ou_path" {
  default = ""
}

variable "local_admin_username" {
  type        = string
  default     = "localadm"
  description = "local admin username"
}

variable "local_admin_password" {
  type        = string
  default     = "ChangeMe123!"
  description = "local admin password"
  sensitive   = true
}