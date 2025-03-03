resource "ibm_is_security_group_rule" "inbound_http" {
  group     = var.vpc_security_group_id
  direction = "inbound"
  tcp {
    port_max = 80
    port_min = 80
  }
}

resource "ibm_is_security_group_rule" "outbound_http" {
  group     = var.vpc_security_group_id
  direction = "outbound"
  tcp {
    port_max = 80
    port_min = 80
  }
}

data "ibm_is_image" "image" {
  name = "ibm-centos-stream-9-amd64-8"
}

data "ibm_is_ssh_key" "key" {
  name = var.existing_ssh_key_name
}

resource "ibm_is_instance" "instance" {

  name           = "${var.basename}-provider-vsi-${data.ibm_is_subnet.vpc_subnet.zone}"
  resource_group = local.resource_group_id
  image          = data.ibm_is_image.image.id
  profile        = var.instance_profile
  primary_network_interface {
    subnet = data.ibm_is_subnet.vpc_subnet.id
    security_groups = [
      var.vpc_security_group_id
    ]
  }
  vpc  = var.vpc_id
  zone = data.ibm_is_subnet.vpc_subnet.zone
  keys = [
    data.ibm_is_ssh_key.key.id
  ]

  user_data = file("./userdata.sh")
  tags      = concat(var.tags, ["vpc"])
}

resource "ibm_is_floating_ip" "ip" {
  count          = var.create_floating_ips ? 1 : 0
  name   = "${ibm_is_instance.instance.name}-ip"
  target = ibm_is_instance.instance.primary_network_interface[0].id
  resource_group = local.resource_group_id
}

output "connect_to_instance" {
 value = {
    for ip in ibm_is_floating_ip.ip: ip.name => "ssh root@${ip.address}"
  }
}

data "ibm_iam_auth_token" "tokendata" {}

data "ibm_is_subnet" "vpc_subnet" {
	identifier = var.subnet_id
}

provider "restapi" {
  alias = "pps"
  uri                  = local.iaas_endpoint
  debug                = true
  write_returns_object = true
  headers = {
    Authorization = data.ibm_iam_auth_token.tokendata.iam_access_token
  }
}

module "provider_pps" {
  source = "./modules/pps"

  basename = "${var.basename}"
  iaas_endpoint = local.iaas_endpoint
  iaas_endpoint_version = local.iaas_endpoint_version
  resource_group_id = local.resource_group_id
  subnet_id = var.subnet_id
  instance_ids = [ibm_is_instance.instance.id ]
  tags = var.tags
  endpoint = "${var.basename}.example.com"

  providers = {
    restapi = restapi.pps
  }
}

output "pps" {
  value = module.provider_pps.pps
}
