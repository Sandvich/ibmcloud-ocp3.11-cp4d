resource "ibm_compute_vm_instance" "masters" {
    count = var.qty

    hostname = element(var.hostnames, count.index)
    domain = var.domain
    flavor_key_name = var.flavor
    os_reference_code = var.os
    datacenter = var.datacenter
    network_speed = 1000
    ssh_key_ids = var.ssh_id
    local_disk = false
    tags = var.tags
    private_security_group_ids = [ ibm_security_group.master_sg.id ]
    public_security_group_ids = [ ibm_security_group.master_sg.id ]
}