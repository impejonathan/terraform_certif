variable "resource_group_name" {
  description = "Nom du Resource Group"
  type        = string
  default     = "RG-JIMPE-Certif"
}

variable "location" {
  description = "Région Azure"
  type        = string
  default     = "francecentral"
}

variable "storage_account_name" {
  description = "Nom du Storage Account"
  type        = string
  default     = "dlcertifimpe"
}

variable "check_existing" {
  description = "Vérifier si les ressources existent avant de les créer"
  type        = bool
  default     = true
}
