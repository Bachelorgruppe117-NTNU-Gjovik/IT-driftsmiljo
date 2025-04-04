output "subnet_db_id" {
  description = "The id of the subnet for the database"
  value       = azurerm_subnet.subnet_db.id
}

output "subnet_capp_id" {
  description = "The id of the subnet for the container apps"
  value       = azurerm_subnet.subnet_capp.id
}
output "privdnszone_id" {
  description = "The id of the provate dns zone"
  value       = azurerm_private_dns_zone.privdnszone.id
}

