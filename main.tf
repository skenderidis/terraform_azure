provider "azurerm" {
  features {}
}

#
# Create a random id
#
resource "random_string" "suffix" {
  length  = 3
  special = false
}

#
# Create a resource group
#
resource "azurerm_resource_group" "f5_rg" {
  name     = "${var.f5_rg_name}-${random_string.suffix.result}"
  location = var.location
}

resource "azurerm_ssh_public_key" "f5_key" {
  name                = format("%s-pubkey-%s", var.prefix, random_string.suffix.result)
  resource_group_name = azurerm_resource_group.f5_rg.name
  location            = azurerm_resource_group.f5_rg.location
  public_key          = file("~/.ssh/id_rsa.pub")
}

# Create the Secure VNET 
resource "azurerm_virtual_network" "f5_vnet" {
  name                = var.f5_vnet_name
  address_space       = [var.f5_vnet_cidr]
  resource_group_name = azurerm_resource_group.f5_rg.name
  location            = azurerm_resource_group.f5_rg.location
  tags = {
    owner = var.tag
  }
}


##############################################
		######## Create subnets ########
##############################################

resource "azurerm_subnet" "mgmt_subnet" {
  name                 = var.mgmt_subnet_name
  address_prefixes       = [var.mgmt_subnet_cidr]
  virtual_network_name = azurerm_virtual_network.f5_vnet.name
  resource_group_name  = azurerm_resource_group.f5_rg.name 
}

resource "azurerm_subnet" "ext_subnet" {
  name                 = var.ext_subnet_name
  address_prefixes     = [var.ext_subnet_cidr]
  virtual_network_name = azurerm_virtual_network.f5_vnet.name
  resource_group_name  = azurerm_resource_group.f5_rg.name 
}

resource "azurerm_subnet" "int_subnet" {
  name                 = var.int_subnet_name
  address_prefixes     = [var.int_subnet_cidr]
  virtual_network_name = azurerm_virtual_network.f5_vnet.name
  resource_group_name  = azurerm_resource_group.f5_rg.name 
}




##############################################
		######## Create NSG ########
##############################################


# Create Network Security Group to access F5 mgmt
resource "azurerm_network_security_group" "f5_nsg_mgmt" {

  name                = "${var.f5_vnet_name}-f5_mgmt-nsg"
  location            = azurerm_resource_group.f5_rg.location
  resource_group_name = azurerm_resource_group.f5_rg.name 

  security_rule {
    name                       = "allow-ssh"
    description                = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.AllowedIPs
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https"
    description                = "allow-https"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = var.AllowedIPs
    destination_address_prefix = "*"
  }
  tags = {
    owner = var.tag
  }
}

# Create Network Security Group to access F5 ext
resource "azurerm_network_security_group" "f5_nsg_ext" {

  name                = "${var.f5_vnet_name}-f5_ext-nsg"
  location            = azurerm_resource_group.f5_rg.location
  resource_group_name = azurerm_resource_group.f5_rg.name 

  security_rule {
    name                       = "allow-http"
    description                = "allow-http"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefixes    = var.AllowedIPs
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https"
    description                = "allow-https"
    priority                   = 122
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = var.AllowedIPs
    destination_address_prefix = "*"
  }
  
  tags = {
    owner = var.tag
  }
}

module "bigip1" {
  source                      = "./modules/bigip"
  prefix                      = "bigip01"
  resource_group_name         = azurerm_resource_group.f5_rg.name
  f5_ssh_publickey            = azurerm_ssh_public_key.f5_key.public_key
  mgmt_subnet_id 	            = azurerm_subnet.mgmt_subnet.id
  mgmt_nsg_id	  	            = azurerm_network_security_group.f5_nsg_mgmt.id
  ext_subnet_id 	            = azurerm_subnet.ext_subnet.id
  ext_nsg_id		              = azurerm_network_security_group.f5_nsg_ext.id
  int_subnet_id 	            = azurerm_subnet.int_subnet.id
  self_ip_mgmt 		            = var.self_ip_mgmt_01
  self_ip_ext 		            = var.self_ip_ext_01
  self_ip_int 		            = var.self_ip_int_01
  add_ip_ext                  = var.add_ip_ext_01
  f5_password                 = var.password
  f5_username                 = var.username
  availability_zone           = var.availability_zone
  availabilityZones_public_ip = var.availabilityZones_public_ip
}

module "bigip2" {
  source                      = "./modules/bigip"
  prefix                      = "bigip02"
  resource_group_name         = azurerm_resource_group.f5_rg.name
  f5_ssh_publickey            = azurerm_ssh_public_key.f5_key.public_key
  mgmt_subnet_id 	            = azurerm_subnet.mgmt_subnet.id
  mgmt_nsg_id	  	            = azurerm_network_security_group.f5_nsg_mgmt.id
  ext_subnet_id 	            = azurerm_subnet.ext_subnet.id
  ext_nsg_id		              = azurerm_network_security_group.f5_nsg_ext.id
  int_subnet_id 	            = azurerm_subnet.int_subnet.id
  self_ip_mgmt 		            = var.self_ip_mgmt_02
  self_ip_ext 		            = var.self_ip_ext_02
  self_ip_int 		            = var.self_ip_int_02
  add_ip_ext                  = var.add_ip_ext_02
  f5_password                 = var.password
  f5_username                 = var.username
  availability_zone           = var.availability_zone
  availabilityZones_public_ip = var.availabilityZones_public_ip
}


data "template_file" "tmpl_bigip1" {
  template = "${file("./modules/bigip/templates/onboard_do_3nic.tpl")}"
  vars = {
    hostname      = module.bigip1.mgmtPublicDNS
    name_servers  = "169.254.169.253"
    search_domain = "f5.com"
    ntp_servers   = "169.254.169.123"
    self-ip1      = var.self_ip_ext_01
    self-ip2      = var.self_ip_int_01
    gateway       = join(".", concat(slice(split(".", "10.1.10.0/24"), 0, 3), [1]))
  }
  depends_on = [module.bigip1.mgmtPublicDNS, module.bigip2.mgmtPublicDNS]
}

resource "null_resource" "do_bigip1" {

  provisioner "local-exec" {
    command = "cat > primary-bigip.json <<EOL\n ${data.template_file.tmpl_bigip1.rendered}\nEOL"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf primary-bigip.json"
  }
}

data "template_file" "tmpl_bigip2" {
  template = "${file("./modules/bigip/templates/onboard_do_3nic.tpl")}"
  vars = {
    hostname      = module.bigip2.mgmtPublicDNS
    name_servers  = "169.254.169.253"
    search_domain = "f5.com"
    ntp_servers   = "169.254.169.123"
    self-ip1      = var.self_ip_ext_02
    self-ip2      = var.self_ip_int_02
    gateway       = join(".", concat(slice(split(".", "10.1.10.0/24"), 0, 3), [1]))
  }
  depends_on = [module.bigip1.mgmtPublicDNS, module.bigip2.mgmtPublicDNS]
}


resource "null_resource" "do_bigip2" {

  provisioner "local-exec" {
    command = "cat > secondary-bigip.json <<EOL\n ${data.template_file.tmpl_bigip2.rendered}\nEOL"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf secondary-bigip.json"
  }
}


resource "null_resource" "do_script_bigip01" {
  provisioner "local-exec" {
    command = "./do-script.sh"
    environment = {
      TF_VAR_bigip_ip  = module.bigip1.mgmtPublicIP
      TF_VAR_username  = var.username
      TF_VAR_password  = var.password
      TF_VAR_json_file = "primary-bigip.json"
      TF_VAR_prefix = "bigip01"
    }
  }
  provisioner "local-exec" {
    when    = destroy
    command = "ls -la"
    # This is where you can configure the BIGIQ revole API
  }
  depends_on = [null_resource.do_bigip1]
}

resource "null_resource" "do_script_bigip02" {
  provisioner "local-exec" {
    command = "./do-script.sh"
    environment = {
      TF_VAR_bigip_ip  = module.bigip2.mgmtPublicIP
      TF_VAR_username  = var.username
      TF_VAR_password  = var.password
      TF_VAR_json_file = "secondary-bigip.json"
      TF_VAR_prefix = "bigip02"
    }
  }
  provisioner "local-exec" {
    when    = destroy
    command = "ls -la"
    # This is where you can configure the BIGIQ revole API
  }
    depends_on = [null_resource.do_bigip2]

}