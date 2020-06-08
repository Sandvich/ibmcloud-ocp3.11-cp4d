resource "ibm_compute_vm_instance" "master" {
  count = var.qty

  hostname                   = element(var.hostnames, count.index)
  domain                     = var.domain
  flavor_key_name            = var.flavor
  os_reference_code          = var.os
  network_speed              = 1000
  ssh_key_ids                = var.ssh_id
  local_disk                 = false
  tags                       = var.tags
  disks                      = [100]
  private_security_group_ids = [ibm_security_group.master_sg.id]
  public_security_group_ids  = [ibm_security_group.master_sg.id]
  datacenter                 = var.datacenter
  public_vlan_id             = var.public_vlan
  private_vlan_id            = var.private_vlan
  public_subnet              = var.public_subnet
  private_subnet             = var.private_subnet
}