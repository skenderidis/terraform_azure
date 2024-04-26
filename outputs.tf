output "resourcegroup_name" {
  description = "Resource Group in which objects are created"
  value       = azurerm_resource_group.f5_rg.name
}

output "resourcegroup_location" {
  description = "Resource Group in which objects are created"
  value       = azurerm_resource_group.f5_rg.location
}

output "Primary_mgmtPublicIP" {
  value = module.bigip1.mgmtPublicIP
}

output "Primary_mgmtPublicDNS" {
  value = module.bigip1.mgmtPublicDNS
}


output "Secondary_mgmtPublicIP" {
  value = module.bigip2.mgmtPublicIP
}

output "Secondary_mgmtPublicDNS" {
  value = module.bigip2.mgmtPublicDNS
}

