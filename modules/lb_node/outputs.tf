output "lb_node" {
  value = ibm_compute_vm_instance.lb
}

locals {
  ips = [
    for host in ibm_compute_vm_instance.lb : {
      name       = host.hostname,
      private_ip = host.ipv4_address_private
      public_ip  = host.ipv4_address
    }
  ]
}

output "ips" {
  value = local.ips
}