# -----------------------------------------------------------------------------
# Region & Environment
# -----------------------------------------------------------------------------
variable "aws_region" {
  description = "AWS region"
}

variable "prefix" {
  description = "Prefix for all resource names"
}

variable "environment" {
  description = "Environment name"
}

# -----------------------------------------------------------------------------
# CIDRs
# -----------------------------------------------------------------------------
# VPC
variable "internet_vpc_cidr" {
  description = "Internet VPC CIDR"
}

variable "workload_vpc_cidr" {
  description = "Workload VPC CIDR"
}

# Subnets
variable "firewall_cidr" {
  description = "Firewall Subnet CIDR"
}

variable "gateway_a_cidr" {
  description = "Gateway Subnet A CIDR"
}

variable "gateway_b_cidr" {
  description = "Gateway Subnet B CIDR"
}

variable "internet_tgw_cidr" {
  description = "Internet TGW Subnet CIDR"
}

variable "web_a_cidr" {
  description = "Web Subnet A CIDR"
}

variable "web_b_cidr" {
  description = "Web Subnet B CIDR"
}

variable "workload_tgw_cidr" {
  description = "Workload TGW Subnet CIDR"
}

variable "app_a_cidr" {
  description = "App Subnet A CIDR"
}

variable "app_b_cidr" {
  description = "App Subnet B CIDR"
}

variable "data_a_cidr" {
  description = "Data Subnet A CIDR"
}

variable "data_b_cidr" {
  description = "Data Subnet B CIDR"
}

# -----------------------------------------------------------------------------
# Availability Zones
# -----------------------------------------------------------------------------
variable "az_a" {
  description = "Primary Availability Zone"
}

variable "az_b" {
  description = "Secondary Availability Zone"
}

# -----------------------------------------------------------------------------
# ECS
# -----------------------------------------------------------------------------
variable "container_image" {
  description = "Docker image for the echoserver container"
}

variable "task_cpu" {
  description = "CPU units for the ECS task"
}

variable "task_memory" {
  description = "Memory (MB) for the ECS task"
}

variable "desired_count" {
  description = "Number of ECS tasks to run"
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
}

variable "container_port" {
  description = "Container Port"
}

# -----------------------------------------------------------------------------
# Aurora
# -----------------------------------------------------------------------------
variable "engine_version" {
  description = "Aurora MySQL engine version"
}

variable "database_name" {
  description = "Initial database name"
}

variable "min_capacity" {
  description = "Minimum Aurora Serverless v2 capacity"
}

variable "max_capacity" {
  description = "Maximum Aurora Serverless v2 capacity"
}

variable "db_port" {
  description = "Database Port"
}

# -----------------------------------------------------------------------------
# ALB Port Numbers
# -----------------------------------------------------------------------------
variable "workload_nlb_tg_port" {
  description = "Workload NLB Target Group Port"
}

variable "workload_nlb_lis_port" {
  description = "Workload NLB Listener Port"
}

variable "workload_alb_tg_port" {
  description = "Workload ALB Target Group Port"
}

variable "workload_alb_lis_port" {
  description = "Workload ALB Listener Port"
}

variable "internet_alb_tg_port" {
  description = "Internet ALB Target Group Port"
}

variable "internet_alb_lis_port" {
  description = "Internet ALB Listener Port"
}