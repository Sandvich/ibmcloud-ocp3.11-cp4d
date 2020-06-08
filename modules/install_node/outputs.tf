output "ips" {
  value = {
    "name"       = (ibm_compute_vm_instance.installer.hostname)
    "private_ip" = (ibm_compute_vm_instance.installer.ipv4_address_private)
    "public_ip"  = (ibm_compute_vm_instance.installer.ipv4_address)
  }
}

output "subnets" {
  value = {
    "private" = (ibm_compute_vm_instance.installer.private_subnet)
    "public"  = (ibm_compute_vm_instance.installer.public_subnet)
  }
}