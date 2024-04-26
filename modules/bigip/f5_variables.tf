
variable "mgmt_subnet_id" {
    description = "The Subnet ID that will deploy the mgmt interface"
}
variable "int_subnet_id" {
    description = "The Subnet ID that will deploy the internal interface"
}
variable "ext_subnet_id" {
    description = "The Subnet ID that will deploy the external interface"
}
variable "mgmt_nsg_id" {
    description = "The NSG ID to be used for the mgmt interface"
}
variable "ext_nsg_id" {
    description = "The NSG ID to be used for the external interface"
}

variable "self_ip_mgmt" {
    description = "The Static IP that will be used for the MGMT Interface"
}
variable "self_ip_ext" {
    description = "The Static IP that will be used for the External Interface"
}

variable "self_ip_int" {
    description = "The Static IP that will be used for the Internal Interface"
}
variable "add_ip_ext" {
    description = "The Additional Static IP that will be used for the External Interface"
}
variable "prefix" {
  description = "Prefix for resources created by this module"
  type        = string
}

variable "f5_username" {
  description = "The admin username of the F5 Bigip that will be deployed"
  default     = "bigipuser"
}

variable "f5_password" {
  description = "The admin password of the F5 Bigip that will be deployed"
  default     = ""
}

variable "vm_name" {
  description = "Name of F5 BIGIP VM to be used,it should be unique `name`,default is empty string meaning module adds with prefix + random_id"
  default     = ""
}

variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created"
  type        = string
}


variable "f5_instance_type" {
  description = "Specifies the size of the virtual machine."
  type        = string
  default     = "Standard_D8s_v4"
}

variable "os_disk_size" {
  description = "The size of the Data Disk which should be created"
  type        = number
  default     = 84
}

variable "image_publisher" {
  description = "Specifies product image publisher"
  type        = string
  default     = "f5-networks"
}

variable "f5_image_name" {
  type        = string
  default     = "f5-bigip-virtual-edition-25m-good-hourly-po-f5"
}

variable "f5_product_name" {
  type        = string
  default     = "f5-big-ip-good" 
}

variable "f5_version" {
  type        = string
  default     = "17.1.101000"
}


variable "storage_account_type" {
  description = "Defines the type of storage account to be created. Valid options are Standard_LRS, Standard_ZRS, Standard_GRS, Standard_RAGRS, Premium_LRS."
  default     = "Standard_LRS"
}

variable "enable_accelerated_networking" {
  type        = bool
  description = "(Optional) Enable accelerated networking on Network interface"
  default     = false
}

variable "enable_ssh_key" {
  type        = bool
  description = "(Optional) Enable ssh key authentication in Linux virtual Machine"
  default     = false
}

variable "f5_ssh_publickey" {
  description = "public key to be used for ssh access to the VM. e.g. c:/home/id_rsa.pub"
}


## Please check and update the latest DO URL from https://github.com/F5Networks/f5-declarative-onboarding/releases
# always point to a specific version in order to avoid inadvertent configuration inconsistency
variable "DO_URL" {
  description = "URL to download the BIG-IP Declarative Onboarding module"
  type        = string
  default     = "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.43.0/f5-declarative-onboarding-1.43.0-5.noarch.rpm"
}
## Please check and update the latest AS3 URL from https://github.com/F5Networks/f5-appsvcs-extension/releases/latest 
# always point to a specific version in order to avoid inadvertent configuration inconsistency
variable "AS3_URL" {
  description = "URL to download the BIG-IP Application Service Extension 3 (AS3) module"
  type        = string
  default     = "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.50.1/f5-appsvcs-3.50.1-2.noarch.rpm"
}

## Please check and update the latest TS URL from https://github.com/F5Networks/f5-telemetry-streaming/releases/latest 
# always point to a specific version in order to avoid inadvertent configuration inconsistency
variable "TS_URL" {
  description = "URL to download the BIG-IP Telemetry Streaming module"
  type        = string
  default     = "https://github.com/F5Networks/f5-telemetry-streaming/releases/download/v1.35.0/f5-telemetry-1.35.0-1.noarch.rpm"
}

## Please check and update the latest FAST URL from https://github.com/F5Networks/f5-appsvcs-templates/releases/latest 
# always point to a specific version in order to avoid inadvertent configuration inconsistency
variable "FAST_URL" {
  description = "URL to download the BIG-IP FAST module"
  type        = string
  default     = "https://github.com/F5Networks/f5-appsvcs-templates/releases/download/v1.25.0/f5-appsvcs-templates-1.25.0-1.noarch.rpm"
}

## Please check and update the latest Failover Extension URL from https://github.com/F5Networks/f5-cloud-failover-extension/releases/latest 
# always point to a specific version in order to avoid inadvertent configuration inconsistency
variable "CFE_URL" {
  description = "URL to download the BIG-IP Cloud Failover Extension module"
  type        = string
  default     = "https://github.com/F5Networks/f5-cloud-failover-extension/releases/download/v2.0.2/f5-cloud-failover-2.0.2-2.noarch.rpm"
}

## Please check and update the latest runtime init URL from https://github.com/F5Networks/f5-bigip-runtime-init/releases/latest
# always point to a specific version in order to avoid inadvertent configuration inconsistency
variable "INIT_URL" {
  description = "URL to download the BIG-IP runtime init"
  type        = string
  default     = "https://cdn.f5.com/product/cloudsolutions/f5-bigip-runtime-init/v2.0.1/dist/f5-bigip-runtime-init-2.0.1-1.gz.run"
}

variable "libs_dir" {
  description = "Directory on the BIG-IP to download the A&O Toolchain into"
  default     = "/config/cloud/azure/node_modules"
  type        = string
}
variable "onboard_log" {
  description = "Directory on the BIG-IP to store the cloud-init logs"
  default     = "/var/log/startup-script.log"
  type        = string
}

variable "availability_zone" {
  description = "If you want the VM placed in an Azure Availability Zone, and the Azure region you are deploying to supports it, specify the number of the existing Availability Zone you want to use."
  default     = 1
}

variable "availabilityZones_public_ip" {
  description = "The availability zone to allocate the Public IP in. Possible values are Zone-Redundant, 1, 2, 3, and No-Zone."
  type        = string
  default     = "Zone-Redundant"
}


variable "custom_user_data" {
  description = "Provide a custom bash script or cloud-init script the BIG-IP will run on creation"
  type        = string
  default     = null
}

variable "tags" {
  description = "key:value tags to apply to resources built by the module"
  type        = map(any)
  default     = {}
}

variable "sleep_time" {
  type        = string
  default     = "20s"
  description = "The number of seconds/minutes of delay to build into creation of BIG-IP VMs; default is 250. BIG-IP requires a few minutes to complete the onboarding process and this value can be used to delay the processing of dependent Terraform resources."
}
