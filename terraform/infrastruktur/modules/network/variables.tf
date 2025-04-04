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
  default     = ["10.0.2.0/20"]
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