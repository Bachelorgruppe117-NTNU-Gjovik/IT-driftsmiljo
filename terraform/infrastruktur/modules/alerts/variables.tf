variable "rg_name_alerts" {
  description = "Name of the alerts resource group"
  type        = string
  default     = "rg-alerts"
}

variable "alert_name" {
    description = "Name of the receiver for alerts"
    type = string
}

variable "email_address" {
    description = "Email address of the email receiver for alerts"
    type = string
}

variable "sms_number" {
    description = "Number for the sms receiver for alerts"
    type = number
}

variable "capp_ids" {
    description = "The ids for the container apps"
    type = set(string)
    default = [ ]
}

variable "psql_fs_id" {
    description = "The ids for the PostgreSQL databases"
    type = set(string)
    default = [ ]
}
