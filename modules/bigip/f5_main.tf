terraform {
  required_version = ">= 0.14.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3"
    }
    random = {
      source  = "hashicorp/random"
      version = ">2.3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">2.1.2"
    }
  }
}


#
# Create a random id
#
resource "random_id" "module_id" {
  byte_length = 2
}

data "azurerm_resource_group" "bigiprg" {
  name = var.resource_group_name
}

###########    Create Public IPs   ########
##              only for mgmt            ##

# Create a Public IP for bigip MGMT Interface
resource "azurerm_public_ip" "mgmt_public_ip" {
  name                = "${var.prefix}-pip-mgmt"
  location            = data.azurerm_resource_group.bigiprg.location
  resource_group_name = data.azurerm_resource_group.bigiprg.name
  domain_name_label   = "${var.prefix}-mgmt"
  allocation_method   = "Static"   # Static is required due to the use of the Standard sku
  sku                 = "Standard" # the Standard sku is required due to the use of availability zones
//  tags = merge(local.tags, {
//    Name = format("%s-pip-mgmt-%s", local.instance_prefix, count.index)
//    }
//  )
}


###########    Create BIGIP Interfaces   ########

# Create MGMT Interface
resource "azurerm_network_interface" "mgmt_nic" {
  name                = "${var.prefix}-mgmt-nic"
  location            = data.azurerm_resource_group.bigiprg.location
  resource_group_name = data.azurerm_resource_group.bigiprg.name
  ip_configuration {
    name                          = "${var.prefix}-mgmt-ip"
    subnet_id                     = var.mgmt_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.self_ip_mgmt
    public_ip_address_id          = azurerm_public_ip.mgmt_public_ip.id
  }
//  tags = merge(local.tags, {
//    Name = format("%s-mgmt-nic-%s", local.instance_prefix, count.index)
//    }
//  )
}


# Create External Interface
resource "azurerm_network_interface" "external_nic" {
  name                 = "${var.prefix}-ext-nic"
  location             = data.azurerm_resource_group.bigiprg.location
  resource_group_name  = data.azurerm_resource_group.bigiprg.name
  enable_ip_forwarding = true
  ip_configuration {
    name                          = "${var.prefix}-ext-ip"
    subnet_id                     = var.ext_subnet_id
    primary                       = "true"
    private_ip_address_allocation = "Static"
    private_ip_address            = var.self_ip_ext
  }
  ip_configuration {
    name                          = "${var.prefix}-secondary-ext-ip"
    subnet_id                     = var.ext_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.add_ip_ext
  }
//  tags = merge(local.tags, var.externalnic_failover_tags, {
//    Name = format("%s-ext-nic-%s", local.instance_prefix, count.index),
//    }
//  )
}

# Create Internal Interface
resource "azurerm_network_interface" "internal_nic" {
  name                = "${var.prefix}-int-nic"
  location            = data.azurerm_resource_group.bigiprg.location
  resource_group_name = data.azurerm_resource_group.bigiprg.name
  //enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = "${var.prefix}-int-ip"
    subnet_id                     = var.int_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.self_ip_int
    //public_ip_address_id          = length(azurerm_public_ip.mgmt_public_ip.*.id) > count.index ? azurerm_public_ip.mgmt_public_ip[count.index].id : ""
  }
//  tags = merge(local.tags, var.internalnic_failover_tags, {
//    Name = format("%s-internal-nic-%s", local.instance_prefix, count.index)
//    }
//  )
}

#########         Associate  Interfaces with NSG        ########

# Mgmt Interfaces NSG association
resource "azurerm_network_interface_security_group_association" "mgmt_security" {
  network_interface_id      = azurerm_network_interface.mgmt_nic.id
  network_security_group_id = var.mgmt_nsg_id
}

# Ext Interfaces NSG association
resource "azurerm_network_interface_security_group_association" "external_security" {
  network_interface_id      = azurerm_network_interface.external_nic.id
  network_security_group_id = var.ext_nsg_id
}


# Create F5 BIGIP1
resource "azurerm_linux_virtual_machine" "f5vm01" {
  name                            = "vm-${var.prefix}"
  location                        = data.azurerm_resource_group.bigiprg.location
  resource_group_name             = data.azurerm_resource_group.bigiprg.name
  network_interface_ids           = [azurerm_network_interface.mgmt_nic.id, azurerm_network_interface.external_nic.id, azurerm_network_interface.internal_nic.id]
  size                            = var.f5_instance_type
  disable_password_authentication = var.enable_ssh_key
  computer_name                   = "f5vm-${var.prefix}"
  admin_username                  = var.f5_username
  admin_password                  = var.f5_password
  custom_data = base64encode(coalesce(var.custom_user_data, templatefile("${path.module}/templates/f5_onboard.tmpl",
    {
      INIT_URL                   = var.INIT_URL
      DO_URL                     = var.DO_URL
      AS3_URL                    = var.AS3_URL
      TS_URL                     = var.TS_URL
      CFE_URL                    = var.CFE_URL
      FAST_URL                   = var.FAST_URL,
      DO_VER                     = format("v%s", split("-", split("/", var.DO_URL)[length(split("/", var.DO_URL)) - 1])[3])
      AS3_VER                    = format("v%s", split("-", split("/", var.AS3_URL)[length(split("/", var.AS3_URL)) - 1])[2])
      TS_VER                     = format("v%s", split("-", split("/", var.TS_URL)[length(split("/", var.TS_URL)) - 1])[2])
      CFE_VER                    = format("v%s", split("-", split("/", var.CFE_URL)[length(split("/", var.CFE_URL)) - 1])[3])
      FAST_VER                   = format("v%s", split("-", split("/", var.FAST_URL)[length(split("/", var.FAST_URL)) - 1])[3])
      bigip_username             = var.f5_username
      bigip_password             = var.f5_password
      ssh_keypair                = var.f5_ssh_publickey
  })))
  source_image_reference {
    offer     = var.f5_product_name
    publisher = var.image_publisher
    sku       = var.f5_image_name
    version   = var.f5_version
  }

  os_disk {
    caching                   = "ReadWrite"
    disk_size_gb              = var.os_disk_size
    name                      = "${var.prefix}-osdisk-f5vm"
    storage_account_type      = var.storage_account_type
    write_accelerator_enabled = false
  }

  admin_ssh_key {
    public_key = var.f5_ssh_publickey
    username   = var.f5_username
  }
  plan {
    name      = var.f5_image_name
    product   = var.f5_product_name
    publisher = var.image_publisher
  }
  zone = var.availability_zone

//  tags = merge(local.tags, {
//    Name = format("%s-f5vm01", local.instance_prefix)
//    }
//  )
//  identity {
//    type         = "UserAssigned"
//    identity_ids = var.user_identity == null ? flatten([azurerm_user_assigned_identity.user_identity.*.id]) : [var.user_identity]
//  }
  depends_on = [azurerm_network_interface_security_group_association.mgmt_security, azurerm_network_interface_security_group_association.external_security]
}

## ..:: Run Startup Script ::..
resource "azurerm_virtual_machine_extension" "vmext" {
  name                 = format("%s-vmext1", var.prefix)
  depends_on           = [azurerm_linux_virtual_machine.f5vm01]
  virtual_machine_id   = azurerm_linux_virtual_machine.f5vm01.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

//  tags = merge(local.tags, {
//    Name = format("%s-vmext1", local.instance_prefix)
//    }
//  )

  settings = <<SETTINGS
    {
      "commandToExecute": "bash /var/lib/waagent/CustomData; exit 0;"
    }
SETTINGS
}

resource "time_sleep" "wait_for_azurerm_virtual_machine_f5vm" {
  depends_on      = [azurerm_virtual_machine_extension.vmext]
  create_duration = var.sleep_time
}

# Getting Public IP Assigned to BIGIP
# data "azurerm_public_ip" "f5vm01mgmtpip" {
#   name                = azurerm_public_ip.mgmt_public_ip[0].name
#   resource_group_name = data.azurerm_resource_group.bigiprg.name
#   depends_on          = [azurerm_virtual_machine.f5vm01, azurerm_virtual_machine_extension.vmext, azurerm_public_ip.mgmt_public_ip[0]]
# }
