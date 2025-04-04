variable "rootPath" {
  description = "Absolute path to infrastructure project"
  type        = string
}

variable "ctemplatePath" {
  description = "Path to container template file"
  type        = string
  default     = "/terraform/infrastruktur/templates/containerObj.json"
}

variable "dbtemplatePath" {
  description = "Path to database template file"
  type        = string
  default     = "/terraform/infrastruktur/templates/databaseObj.json"
}

variable "tfvarsPath" {
  description = "Path to .tfvars.json file"
  type        = string
  default     = "/terraform/infrastruktur/terraform.tfvars.json"
}

# resource group
variable "rg_dynamic" {
  description = "A map of resource groups variables"
  type = map(object({
    name     = string
    location = optional(string, "westeurope")
  }))
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


# Module: containerapp

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
    name = string # "ca_identity_<cApp name>"
    rg   = string
  }))
}

variable "cae_name" {
  description = "Name of the container app enviorment"
  type        = string
  default     = "CA-Enviornment001"
}

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
    targetport     = optional(number, 5000)
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

# Module: database

variable "postgreserver_name" {
  description = "The name of the postgresql server"
  type        = string
  default     = "postgresql-server-001"
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

/*
variable "postgreserver_admin_password" {
  description = "Password for the administrator user"
  type        = string
}
*/

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

variable "postdb" {
  description = "Variables for a postgresql database"
  type = map(object({
    name            = string
    charset         = optional(string, "UTF8")
    collation       = optional(string, "en_US.utf8")
    prevent_destroy = optional(bool, false)
  })) /*
        default = {
            "dfpostdb" = {
            name = "dfdapostdb"
            charset = "UTF8"
            collation = "en_US.utf8"
            prevent_destroy = false
            }
        }*/
}

# Module: network

variable "nsg_name_db" {
  description = "Name of the network security group for databases"
  type        = string
  default     = "nsg-db"
}

variable "nsg_name_capp" {
  description = "Name of the network security group for container apps"
  type        = string
  default     = "nsg-capp"
}


variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "vnet"
}


variable "vnet_addresspace" {
  description = "Addresspace for the virtual network"
  type        = set(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_db_name" {
  description = "Name of the subnet for the database"
  type        = string
  default     = "subnet_db"
}

variable "subnet_capp_name" {
  description = "Name of the subnet for the container apps"
  type        = string
  default     = "subnet_capp"
}

variable "subnet_db_address_prefixes" {
  description = "The address prefixes for the database subnet"
  type        = set(string)
  default     = ["10.0.2.0/24"]
}

variable "subnet_capp_address_prefixes" {
  description = "The address prefixes for the container apps subnet"
  type        = set(string)
  default     = ["10.0.32.0/20"]
}

variable "subnet_service_endpoint" {
  description = "The service endpoints for the subnet"
  type        = set(string)
  default     = ["Microsoft.Storage"]
}

variable "subnet_db_delegation_name" {
  description = "Name of the delegation for the database subnet"
  type        = string
  default     = "db-delegation"
}

variable "subnet_capp_delegation_name" {
  description = "Name of the delegation for the container apps subnet"
  type        = string
  default     = "capp-delegation"
}

variable "subnet_db_service_delegation_name" {
  description = "Name of the delegation service for the database subnet"
  type        = string
  default     = "Microsoft.DBforPostgreSQL/flexibleServers"
}

variable "subnet_capp_service_delegation_name" {
  description = "Name of the delegation service for the container apps subnet"
  type        = string
  default     = "Microsoft.App/environments"
}

variable "subnet_db_service_delegation_actions" {
  description = "Sets of actions for the service delegation for the subnet"
  type        = set(string)
  default     = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
}

variable "subnet_capp_service_delegation_actions" {
  description = "Sets of actions for the service delegation for the subnet"
  type        = set(string)
  default     = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
}

variable "privdnszone_name" {
  description = "Name of the private dns zone"
  type        = string
  default     = "example.postgres.database.azure.com"
}

variable "privdnslink_name" {
  description = "Name of the link between the private dns zone and the virtual network"
  type        = string
  default     = "exampleVnetZone.com"
}

