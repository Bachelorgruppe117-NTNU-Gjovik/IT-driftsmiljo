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

variable "rg_name_storage" {
  description = "Name for storage rg"
  type        = string
}

variable "rg_location_storage" {
  description = "Location for storage rg"
  type        = string
  default     = "westeurope"
}

variable "random_password_db_capp" {
  description = "Generates random password for db secrets"
  type = map(object({
    name = string # "db_password_<cApp name>"
  }))
}

# Identity - KEY NAME OF EACH OBJECT MUST BE IDENTICAL TO CONTAINER APP NAME
variable "ca_identity" {
  description = "Identities for container access to key vault"
  type = map(object({
    name = string # "ca_id_<cApp name>"
    rg   = string
  }))
}




variable "law_name" {
  description = "Name of the log analytics workspace"
  type        = string
  default     = "acc001"
}

variable "law_sku" {
  description = "Unique identifier for log analytics workspace"
  type        = string
  default     = "PerGB2018"
}

variable "law_retention" {
  description = "Renention of data for logs analytics workspace"
  type        = number
  default     = 30
}

variable "cae_name" {
  description = "Name of the container app enviorment"
  type        = string
  default     = "CA-Enviornment001"
}

variable "cenv_subnet_id" {
  description = "The id of the subnet"
  type        = string
}
/*
variable "dbserversecretId" {
  description = "ID of db secret"
  type = string
}
*/
variable "reguname" {
  description = "Username for github container registry"
  type        = string
}

variable "regtoken" {
  description = "Password for github container registry"
  type        = string
}

variable "container" {
  description = "A map of variables for container"
  type = map(object({
    name           = string
    revmode        = optional(string, "Single")
    regserver      = optional(string, "ghcr.io")
    trafficweight  = optional(number, 100)
    latestrevision = optional(bool, true)
    targetport     = optional(number, 8080)
    external       = optional(bool, true)
    ip_restriction_range = string
    image          = string
    cpu            = optional(number, 0.25)
    memory         = optional(string, "0.5Gi")
    rg             = string
  }))
  /*
        default = {
          "dfcontainer" = {
            name = "dfmc-app"
            revmode = optional(string,"Single")
            regserver = optional(string,"ghcr.io")
            reguname = "test"
            regtoken = "test"
            trafficweight = optional(number,100)
            latestrevision = true
            targetport = 5000
            external = true
            image = "ghcr.io/bachelorgruppe117-ntnu-gjovik/testwebapp-app:latest"
            cpu = 0.25
            memory = "0.5Gi"
            rg = "rgstatic001"
          }
        }
        */
}