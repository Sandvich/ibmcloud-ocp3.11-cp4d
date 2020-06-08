output "private_vlan" {
  value = ibm_network_vlan.private_vlan.id
}

output "public_vlan" {
  value = ibm_network_vlan.public_vlan.id
}