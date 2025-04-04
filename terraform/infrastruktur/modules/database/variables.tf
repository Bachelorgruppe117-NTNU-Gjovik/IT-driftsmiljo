variable "rg_name_dynamic" {
  description = "Name of the resource group"
  type        = string
  default     = "rgname001"
}

variable "rg_name_static" {
  description = "Static name for resourcegroup used for shared resources"
  type        = string
  default     = "rgstatic001"
}

variable "rg_location_static" {
  description = "Static location for resourcegroup used for shared resources"
  type        = string
  default     = "westeurope"
}

variable "postgreserver_name" {
  description = "The name of the postgresql server"
  type        = string
  default     = "postgresql-flexible-server"
}

variable "postgreserver_skuname" {
  description = "Name of the sku for the postgresql server"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "postgreserver_storage_mb" {
  description = "Maximum storage capacity for the postgresql server"
  type        = number
  default     = 32768
}

variable "postgreserver_storage_tier" {
  description = "Storage toer for the postgresql flexible server"
  type        = string
  default     = "P4"
}

variable "postgreserver_backup_retention" {
  description = "Retention of backup for the postgresql server in days"
  type        = number
  default     = 7
}

variable "postgreserver_redundant_backup" {
  description = "Choose between locally redundant or geo-redundant backup"
  type        = bool
  default     = false
}

variable "postgreserver_auto_grow" {
  description = "Enable auto grow for the posrgresql server"
  type        = bool
  default     = true
}

variable "postgreserver_admin_uname" {
  description = "Username for the administrator user"
  type        = string
  default     = "ntnuadmin"
}

variable "postgreserver_admin_password" {
  description = "Password for the administrator user"
  type        = string
}

variable "postgreserver_version" {
  description = "Version number of the postgresql server"
  type        = string
  default     = "14"
}

variable "postgreserver_public_network_access" {
  description = "Enable public network access"
  type        = bool
  default     = false
}

variable "postgreserver_zone" {
  description = "The zone for the postgresql flexible server"
  type        = string
  default     = "1"
}

variable "subnet_id" {
  description = "The id of the subnet"
  type        = string
}


variable "privdnszone_id" {
  description = "The id of the private dns zone"
  type        = string
}

variable "postdb" {
  description = "Variables for a postgresql database"
  type = map(object({
    name            = string
    charset         = optional(string, "UTF8")
    collation       = optional(string, "en_US.utf8")
    prevent_destroy = optional(bool, false)
  }))
}