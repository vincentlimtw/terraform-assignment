aws_region        = "ap-southeast-1"
prefix            = "echoserver"
environment       = "dev"
internet_vpc_cidr = "10.0.0.0/16"
workload_vpc_cidr = "10.1.0.0/16"
internet_subnets = {
  firewall     = { cidr = "10.0.1.0/24", az = "ap-southeast-1a" }
  gateway-a    = { cidr = "10.0.2.0/24", az = "ap-southeast-1a" }
  gateway-b    = { cidr = "10.0.3.0/24", az = "ap-southeast-1b" }
  internet-tgw = { cidr = "10.0.4.0/24", az = "ap-southeast-1a" }
}
workload_subnets = {
  web-a        = { cidr = "10.1.1.0/24", az = "ap-southeast-1a" }
  web-b        = { cidr = "10.1.2.0/24", az = "ap-southeast-1b" }
  workload-tgw = { cidr = "10.1.3.0/24", az = "ap-southeast-1a" }
  app-a        = { cidr = "10.1.4.0/24", az = "ap-southeast-1a" }
  app-b        = { cidr = "10.1.5.0/24", az = "ap-southeast-1b" }
  data-a       = { cidr = "10.1.6.0/24", az = "ap-southeast-1a" }
  data-b       = { cidr = "10.1.7.0/24", az = "ap-southeast-1b" }
}
container_image       = "k8s.gcr.io/e2e-test-images/echoserver:2.5"
task_cpu              = 256
task_memory           = 512
desired_count         = 1
log_retention_days    = 7
container_port        = 8080
engine_version        = "8.0.mysql_aurora.3.04.0"
database_name         = "echoserver"
min_capacity          = 0.5
max_capacity          = 4.0
db_port               = 3306
workload_nlb_tg_port  = 80
workload_nlb_lis_port = 80
workload_alb_tg_port  = 8080
workload_alb_lis_port = 80
internet_alb_tg_port  = 80
internet_alb_lis_port = 80
