module "vpc" {
  source            = "./modules/vpc"
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
  source            = "./modules/tgw"
  prefix            = local.prefix
  environment       = var.environment
  internet_vpc_id   = module.vpc.internet_vpc_id
  workload_vpc_id   = module.vpc.workload_vpc_id
  internet_tgw_id   = module.vpc.internet_tgw_id
  workload_tgw_id   = module.vpc.workload_tgw_id
  internet_vpc_cidr = var.internet_vpc_cidr
  workload_vpc_cidr = var.workload_vpc_cidr
}

module "nat" {
  source      = "./modules/nat"
  prefix      = local.prefix
  environment = var.environment
  gateway_a   = module.vpc.gateway_a_id
}

module "routing" {
  source            = "./modules/routing"
  prefix            = local.prefix
  environment       = var.environment
  internet_vpc_id   = module.vpc.internet_vpc_id
  igw_id            = module.vpc.igw_id
  workload_vpc_cidr = var.workload_vpc_cidr
  tgw_id            = module.tgw.tgw_id
  gateway_a_id      = module.vpc.gateway_a_id
  gateway_b_id      = module.vpc.gateway_b_id
  nat_gateway_id    = module.nat.nat_gateway_id
  internet_tgw_id   = module.vpc.internet_tgw_id
  workload_vpc_id   = module.vpc.workload_vpc_id
  web_a_id          = module.vpc.web_a_id
  web_b_id          = module.vpc.web_b_id
  app_a_id          = module.vpc.app_a_id
  app_b_id          = module.vpc.app_b_id
}

module "security" {
  source                = "./modules/security"
  prefix                = local.prefix
  environment           = var.environment
  internet_vpc_id       = module.vpc.internet_vpc_id
  workload_vpc_id       = module.vpc.workload_vpc_id
  internet_vpc_cidr     = var.internet_vpc_cidr
  workload_vpc_cidr     = var.workload_vpc_cidr
  internet_alb_lis_port = var.internet_alb_lis_port
  workload_alb_lis_port = var.workload_alb_lis_port
  workload_nlb_lis_port = var.workload_nlb_lis_port
  container_port        = var.container_port
  db_port               = var.db_port
}

module "alb" {
  source                = "./modules/alb"
  prefix                = local.prefix
  environment           = var.environment
  internet_vpc_id       = module.vpc.internet_vpc_id
  workload_vpc_id       = module.vpc.workload_vpc_id
  gateway_a_id          = module.vpc.gateway_a_id
  gateway_b_id          = module.vpc.gateway_b_id
  web_a_id              = module.vpc.web_a_id
  web_b_id              = module.vpc.web_b_id
  internet_alb_sg_id    = module.security.internet_alb_sg_id
  workload_alb_sg_id    = module.security.workload_alb_sg_id
  workload_nlb_tg_port  = var.workload_nlb_tg_port
  workload_nlb_lis_port = var.workload_nlb_lis_port
  workload_alb_tg_port  = var.workload_alb_tg_port
  workload_alb_lis_port = var.workload_alb_lis_port
  internet_alb_tg_port  = var.internet_alb_tg_port
  internet_alb_lis_port = var.internet_alb_lis_port
}

module "ecs" {
  source              = "./modules/ecs"
  prefix              = local.prefix
  environment         = var.environment
  aws_region          = var.aws_region
  app_a_id            = module.vpc.app_a_id
  app_b_id            = module.vpc.app_b_id
  ecs_sg_id           = module.security.ecs_sg_id
  workload_alb_tg_arn = module.alb.workload_alb_tg_arn
  container_image     = var.container_image
  task_cpu            = var.task_cpu
  task_memory         = var.task_memory
  desired_count       = var.desired_count
  log_retention_days  = var.log_retention_days
  container_port      = var.container_port
}

module "aurora" {
  source         = "./modules/aurora"
  prefix         = local.prefix
  environment    = var.environment
  data_a_id      = module.vpc.data_a_id
  data_b_id      = module.vpc.data_b_id
  aurora_sg_id   = module.security.aurora_sg_id
  engine_version = var.engine_version
  database_name  = var.database_name
  min_capacity   = var.min_capacity
  max_capacity   = var.max_capacity
}