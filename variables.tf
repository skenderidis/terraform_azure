#########   Common Variables   ##########
variable tag 					        {default = "F5 - TF Demo"}
variable password		  		    {default = "Kostas123"}
variable username		  		    {default = "azureuser"}
variable prefix				        {default = "tf-bigip"}
variable location             {default = "westeurope"}
variable "availability_zone"  {default = 1}
variable "availabilityZones_public_ip" {
  description = "The availability zone to allocate the Public IP in. Possible values are Zone-Redundant, 1, 2, 3, and No-Zone."
  type        = string
  default     = "Zone-Redundant"
}

###########   F5  Variables   ############
variable f5_rg_name				{default = "bigip-rg" }
variable f5_vnet_name  			{default = "secure_vnet"}
variable f5_vnet_cidr  			{default = "10.1.0.0/16" }

variable mgmt_subnet_name		{default = "management"}
variable int_subnet_name  		{default = "internal"}
variable ext_subnet_name  		{default = "external" }

variable mgmt_subnet_cidr		{default = "10.1.1.0/24" }
variable int_subnet_cidr  		{default = "10.1.20.0/24" }
variable ext_subnet_cidr  		{default = "10.1.10.0/24" }

variable self_ip_mgmt_01  		{default = "10.1.1.4"}
variable self_ip_ext_01  		{default = "10.1.10.4"}
variable self_ip_int_01  		{default = "10.1.20.4"}
variable self_ip_mgmt_02  		{default = "10.1.1.5"}
variable self_ip_ext_02  		{default = "10.1.10.5"}
variable self_ip_int_02  		{default = "10.1.20.5"}

variable add_ip_ext_01  		{default = "10.1.10.14"}
variable add_ip_ext_02  		{default = "10.1.10.15"}



variable AllowedIPs				{default = ["0.0.0.0/0"]}



########################
#  F5 Image related	   #
########################
#All Image related variables are set on the module variables.tf file

#variable "f5_instance_type" 
#variable "f5_version" 
#variable "image_publisher" 
#variable "f5_image_name" 
#variable "f5_product_name"
#variable "DO_URL" 
#variable "AS3_URL" 
#variable "TS_URL" 
#variable "FAST_URL" 
#variable "CFE_URL" 
#variable "INIT_URL" 
