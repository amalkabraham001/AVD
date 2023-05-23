variable "resource_group_location" {
default     = "eastus"
description = "Location of the resource group."
}

variable "rg_name" {
type        = string
default     = "avd-rg"
description = "Name of the Resource group in which to deploy service objects"
}

variable "workspace" {
type        = string
description = "Name of the Azure Virtual Desktop workspace"
default     = "AVD TF Workspace"
}

variable "hostpool" {
type        = string
description = "Name of the Azure Virtual Desktop host pool"
default     = "AVD-TF-HP"
}

variable "hostpool1" {
type        = string
description = "Name of the Azure Virtual Desktop host pool"
default     = "AVD-Personal-HP"
}

variable "LAG" {
type        = string
description = "Name of the Azure Virtual Desktop host pool"
default     = "AVD-LAG"
}

#variable "rfc3339" {
#type        = string
#default     = timeadd(formatdate("YYYY-MM-01'T'00:00:00Z", timestamp()), "24h")
#description = "Registration token expiration"
#}

variable "prefix" {
type        = string
default     = "avdtf"
description = "Prefix of the name of the AVD machine(s)"
}

variable "vm_size" {
  description = "Size of the machine to deploy"
  default     = "Standard_D2s_v5"
}

variable "rdsh_count" {
  description = "Number of AVD machines to deploy"
  default     = 2
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
