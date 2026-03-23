module "vpc" {
  source            = "../../modules/vpc"
  prefix            = local.prefix
  environment       = var.environment
  internet_vpc_cidr = var.internet_vpc_cidr
  workload_vpc_cidr = var.workload_vpc_cidr
  firewall_cidr     = var.firewall_cidr
  gateway_a_cidr    = var.gateway_a_cidr
  gateway_b_cidr    = var.gateway_b_cidr
  internet_tgw_cidr = var.internet_tgw_cidr
  web_a_cidr        = var.web_a_cidr
  web_b_cidr        = var.web_b_cidr
  workload_tgw_cidr = var.workload_tgw_cidr
  app_a_cidr        = var.app_a_cidr
  app_b_cidr        = var.app_b_cidr
  data_a_cidr       = var.data_a_cidr
  data_b_cidr       = var.data_b_cidr
  az_a              = var.az_a
  az_b              = var.az_b
}

module "tgw" {
  source            = "../../modules/tgw"
  prefix            = local.prefix
  environment       = var.environment
  internet_vpc_id   = module.vpc.internet_vpc_id
  workload_vpc_id   = module.vpc.workload_vpc_id
  internet_tgw_id   = module.vpc.internet_tgw_id
  workload_tgw_id   = module.vpc.workload_tgw_id
  internet_vpc_cidr = var.internet_vpc_cidr
  workload_vpc_cidr = var.workload_vpc_cidr
}