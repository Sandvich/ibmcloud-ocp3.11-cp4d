locals {
  workers = {
    for instance in var.worker: 
      instance.id => instance.ipv4_address
  }

  masters = {
    for instance in ibm_compute_vm_instance.master:
      instance.id => instance.ipv4_address
  }
}

resource "ibm_security_group" "master_sg" {
  name        = "master.${var.domain}-sg"
  description = "Master security group for ${var.domain}"
}

resource "ibm_security_group_rule" "master_ssh" {
  direction         = "ingress"
  port_range_min    = 22
  port_range_max    = 22
  protocol          = "tcp"
  security_group_id = ibm_security_group.master_sg.id
}

resource "ibm_security_group_rule" "master_sdn_self" {
  for_each = local.masters
  direction         = "ingress"
  port_range_min    = 4789
  port_range_max    = 4789
  protocol          = "udp"
  security_group_id = ibm_security_group.master_sg.id
  remote_ip         = each.value
}

resource "ibm_security_group_rule" "master_sdn_worker" {
  for_each = local.workers
  direction         = "ingress"
  port_range_min    = 4789
  port_range_max    = 4789
  protocol          = "udp"
  security_group_id = ibm_security_group.master_sg.id
  remote_ip         = each.value
}

resource "ibm_security_group_rule" "master_etcd" {
  for_each = local.workers
  direction         = "ingress"
  port_range_min    = 2379
  port_range_max    = 2379
  protocol          = "tcp"
  security_group_id = ibm_security_group.master_sg.id
  remote_ip         = each.value
}

resource "ibm_security_group_rule" "master_etcd_self" {
  for_each = local.masters
  direction         = "ingress"
  port_range_min    = 2379
  port_range_max    = 2380
  protocol          = "tcp"
  security_group_id = ibm_security_group.master_sg.id
  remote_ip         = each.value
}

resource "ibm_security_group_rule" "master_api_metrics" {
  direction         = "ingress"
  port_range_min    = 8443
  port_range_max    = 8444
  protocol          = "tcp"
  security_group_id = ibm_security_group.master_sg.id
}

resource "ibm_security_group_rule" "master_dns_tcp" {
  for_each = local.workers
  direction         = "ingress"
  port_range_min    = 8053
  port_range_max    = 8053
  protocol          = "tcp"
  security_group_id = ibm_security_group.master_sg.id
  remote_ip         = each.value
}

resource "ibm_security_group_rule" "master_dns_udp" {
  for_each = local.workers
  direction         = "ingress"
  port_range_min    = 8053
  port_range_max    = 8053
  protocol          = "udp"
  security_group_id = ibm_security_group.master_sg.id
  remote_ip         = each.value
}

resource "ibm_security_group_rule" "master_kubelet" {
  for_each = local.workers
  direction         = "ingress"
  port_range_min    = 10250
  port_range_max    = 10250
  protocol          = "tcp"
  security_group_id = ibm_security_group.master_sg.id
  remote_ip         = each.value
}

resource "ibm_security_group_rule" "master_kubelet_self" {
  for_each = local.masters  
  direction         = "ingress"
  port_range_min    = 10250
  port_range_max    = 10250
  protocol          = "tcp"
  security_group_id = ibm_security_group.master_sg.id
  remote_ip         = each.value
}

resource "ibm_security_group_rule" "master_https" {
  direction         = "ingress"
  port_range_min    = 443
  port_range_max    = 443
  protocol          = "tcp"
  security_group_id = ibm_security_group.master_sg.id
}

resource "ibm_security_group_rule" "master_http" {
  direction         = "ingress"
  port_range_min    = 80
  port_range_max    = 80
  protocol          = "tcp"
  security_group_id = ibm_security_group.master_sg.id
}

resource "ibm_security_group_rule" "egress_public" {
  direction         = "egress"
  security_group_id = ibm_security_group.master_sg.id
}