provider "ibm" {
  ibmcloud_api_key      = var.ibmcloud_api_key
  iaas_classic_username = var.iaas_classic_username
  iaas_classic_api_key  = var.iaas_classic_api_key
  region                = var.region
  generation            = var.generation
}

locals {
  cluster_domain = join(".", [var.cluster_name, var.domain])
  ssh_keys = concat([
    for key in data.ibm_compute_ssh_key.ssh_key : key.id
    ],
    [
      ibm_compute_ssh_key.cluster_ssh_key.id
  ])
  lb_count = var.master_qty > 1 ? 1 : 0
}

data "ibm_compute_ssh_key" "ssh_key" {
  count = length(var.ssh_key)
  label = var.ssh_key[count.index]
}

resource "tls_private_key" "new_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "ibm_compute_ssh_key" "cluster_ssh_key" {
  label      = local.cluster_domain
  public_key = tls_private_key.new_ssh_key.public_key_openssh
  tags       = var.tags
  notes      = "created by terraform"
}

module "vlan" {
  source = "./modules/vlan"

  cluster_name = var.cluster_name
  datacenter   = var.datacenter
  tags         = var.tags
}

module "install" {
  source = "./modules/install_node"

  hostname     = "installer"
  hostnames    = var.master_name
  domain       = local.cluster_domain
  qty          = var.master_qty
  flavor       = var.installer_flavor
  os           = var.installer_os_reference
  ssh_id       = local.ssh_keys
  tags         = var.tags
  datacenter   = var.datacenter
  public_vlan  = module.vlan.public_vlan
  private_vlan = module.vlan.private_vlan
  ssh_key      = tls_private_key.new_ssh_key
}

module "master" {
  source = "./modules/master_node"

  hostnames      = var.master_name
  domain         = local.cluster_domain
  qty            = var.master_qty
  flavor         = var.master_flavor
  os             = var.os_reference
  ssh_id         = local.ssh_keys
  tags           = var.tags
  datacenter     = var.datacenter
  public_vlan    = module.vlan.public_vlan
  private_vlan   = module.vlan.private_vlan
  public_subnet  = module.install.subnets.public
  private_subnet = module.install.subnets.private
}

module "lb" {
  source = "./modules/lb_node"

  hostname       = var.lb_name
  domain         = local.cluster_domain
  qty            = local.lb_count
  flavor         = var.lb_flavor
  os             = var.os_reference
  ssh_id         = local.ssh_keys
  tags           = var.tags
  datacenter     = var.datacenter
  master_sg      = module.master.security_group
  public_vlan    = module.vlan.public_vlan
  private_vlan   = module.vlan.private_vlan
  public_subnet  = module.install.subnets.public
  private_subnet = module.install.subnets.private
}

module "worker" {
  source = "./modules/worker_node"

  hostnames      = var.worker_name
  domain         = local.cluster_domain
  qty            = var.worker_qty
  flavor         = var.worker_flavor
  os             = var.os_reference
  ssh_id         = local.ssh_keys
  tags           = var.tags
  datacenter     = var.datacenter
  public_vlan    = module.vlan.public_vlan
  private_vlan   = module.vlan.private_vlan
  public_subnet  = module.install.subnets.public
  private_subnet = module.install.subnets.private
}

module "prepare_ansible" {
  source = "./modules/prepare_ansible"

  rh_user        = var.redhat_un
  rh_pass        = var.redhat_pw
  pool_id        = var.openshift_pool_id
  ssh_key        = tls_private_key.new_ssh_key
  installer      = module.install.ips
  master         = module.master.ips
  workers        = module.worker.ips
  lb             = module.lb.ips
  cluster_domain = local.cluster_domain
  wsl_install    = var.wsl_install
  wkc_install    = var.wkc_install
  wkc_patch      = var.wkc_patch
  namespace      = var.namespace
  subnet         = module.install.subnets.public
}

module "dns" {
  source = "./modules/dns"

  domain       = var.domain
  cluster_name = var.cluster_name
  master       = module.master.master_node
  worker       = module.worker.worker_nodes
  lb           = module.lb.lb_node
  master_qty   = var.master_qty
}