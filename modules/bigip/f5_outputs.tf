output "mgmtPublicIP" {
  description = "The actual ip address allocated for the resource."
  value       = azurerm_public_ip.mgmt_public_ip.ip_address

}

output "mgmtPublicDNS" {
  description = "fqdn to connect to the first vm provisioned."
  value       = azurerm_public_ip.mgmt_public_ip.fqdn

}


output "f5_username" {
  value = var.f5_username
}

output "bigip_password" {
  value = var.f5_password
}

#output "onboard_do" {
#  value = local.total_nics > 1 ? (local.total_nics == 2 ? local.clustermemberDO2 : local.clustermemberDO3) : local.clustermemberDO1
#}


output "private_addresses" {
  description = "List of BIG-IP private addresses"
  value = {
    mgmt_private = {
      private_ip  = azurerm_network_interface.mgmt_nic.private_ip_address
    }
    external_private = {
      private_ip  = azurerm_network_interface.external_nic.private_ip_address
    }
    internal_private = {
      private_ip  = azurerm_network_interface.internal_nic.private_ip_address
    }
  }
}

output "bigip_instance_ids" {
  value = azurerm_linux_virtual_machine.f5vm01.id
}

output "bigip_nic_ids" {
  description = "List of BIG-IP network interface IDs"
  value = {
    mgmt_nics     = azurerm_network_interface.mgmt_nic.id
    external_nics = azurerm_network_interface.external_nic.id
    internal_nics = azurerm_network_interface.internal_nic.id
  }
}