output "master_node" {
  value = ibm_compute_vm_instance.master
}

locals {
  ips = [
    for host in ibm_compute_vm_instance.master : {
      name       = host.hostname,
      private_ip = host.ipv4_address_private
      public_ip  = host.ipv4_address
    }
  ]
}

output "ips" {
  value = local.ips
}

output "security_group" {
  value = ibm_security_group.master_sg
}