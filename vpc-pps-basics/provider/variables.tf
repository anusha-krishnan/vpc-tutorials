variable "region" {
  default = "us-south"
  description = "Region where to create resources."
}

variable "basename" {
  default = "vpc-pps"
  description = "Prefix to use when naming resources. Use only letters and hyphens."
}

variable "tags" {
  default = ["terraform", "pps", "provider"]
}

variable "existing_resource_group_name" {
  default = ""
  description = "Name of an existing resource group where the resources will be created. Leave it empty to create a new resource group."
}

variable "existing_ssh_key_name" {
  description = "Name of an existing VPC SSH key to inject in virtual server instances."
}

variable "create_floating_ips" {
  default = false
  description = "Used for debug only. When set to true, floating IPs will be assigned to all virtual servers."
}

variable "instance_profile" {
  default = "cx2-2x4"
  description = "Profile used by virtual server instances."
}

variable "vpc_security_group_id" {
  default = "r006-b7be185a-6f4e-4400-b92e-ee13414caaaa"
  description = "VPC security group"
}

variable "vpc_id" {

  default = "r006-02220c46-eeec-477a-90fa-810d13973b53"
  description = "Existing vpc id"
}