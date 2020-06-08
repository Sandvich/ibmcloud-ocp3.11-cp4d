resource "ibm_network_vlan" "private_vlan" {
  name       = "${var.cluster_name}-pvt"
  datacenter = var.datacenter
  type       = "PRIVATE"
  tags       = var.tags
}

resource "ibm_network_vlan" "public_vlan" {
  name       = "${var.cluster_name}-pub"
  datacenter = var.datacenter
  type       = "PUBLIC"
  tags       = var.tags
}