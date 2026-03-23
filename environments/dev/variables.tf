# -----------------------------------------------------------------------------
# Region & Environment
# -----------------------------------------------------------------------------
variable "aws_region" {
  description = "AWS region"
  default     = "ap-southeast-1"
}

variable "prefix" {
  description = "Prefix for all resource names"
  default     = "echoserver"
}

variable "environment" {
  description = "Environment name"
  default     = "dev"
}

# -----------------------------------------------------------------------------
# CIDRs
# -----------------------------------------------------------------------------
# VPC
variable "internet_vpc_cidr" {
  description = "Internet VPC CIDR"
  default     = "10.0.0.0/16"
}

variable "workload_vpc_cidr" {
  description = "Workload VPC CIDR"
  default     = "10.1.0.0/16"
}

# Subnets
variable "firewall_cidr" {
  description = "Firewall Subnet CIDR"
  default     = "10.0.1.0/24"
}

variable "gateway_a_cidr" {
  description = "Gateway Subnet A CIDR"
  default     = "10.0.2.0/24"
}

variable "gateway_b_cidr" {
  description = "Gateway Subnet B CIDR"
  default     = "10.0.3.0/24"
}

variable "internet_tgw_cidr" {
  description = "Internet TGW Subnet CIDR"
  default     = "10.0.4.0/24"
}

variable "web_a_cidr" {
  description = "Web Subnet A CIDR"
  default     = "10.1.1.0/24"
}

variable "web_b_cidr" {
  description = "Web Subnet B CIDR"
  default     = "10.1.2.0/24"
}

variable "workload_tgw_cidr" {
  description = "Workload TGW Subnet CIDR"
  default     = "10.1.3.0/24"
}

variable "app_a_cidr" {
  description = "App Subnet A CIDR"
  default     = "10.1.4.0/24"
}

variable "app_b_cidr" {
  description = "App Subnet B CIDR"
  default     = "10.1.5.0/24"
}

variable "data_a_cidr" {
  description = "Data Subnet A CIDR"
  default     = "10.1.6.0/24"
}

variable "data_b_cidr" {
  description = "Data Subnet B CIDR"
  default     = "10.1.7.0/24"
}

# -----------------------------------------------------------------------------
# Availability Zones
# -----------------------------------------------------------------------------
variable "az_a" {
  description = "Primary Availability Zone"
  default     = "ap-southeast-1a"
}

variable "az_b" {
  description = "Secondary Availability Zone"
  default     = "ap-southeast-1b"
}

# -----------------------------------------------------------------------------
# ECS
# -----------------------------------------------------------------------------
variable "container_image" {
  description = "Docker image for the echoserver container"
  default     = "k8s.gcr.io/e2e-test-images/echoserver:2.5"
}

variable "task_cpu" {
  description = "CPU units for the ECS task"
  default     = 256
}

variable "task_memory" {
  description = "Memory (MB) for the ECS task"
  default     = 512
}

variable "desired_count" {
  description = "Number of ECS tasks to run"
  default     = 1
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  default     = 7
}

# -----------------------------------------------------------------------------
# Aurora
# -----------------------------------------------------------------------------
variable "engine_version" {
  description = "Aurora MySQL engine version"
  default     = "8.0.mysql_aurora.3.04.0"
}

variable "database_name" {
  description = "Initial database name"
  default     = "echoserver"
}

variable "min_capacity" {
  description = "Minimum Aurora Serverless v2 capacity"
  default     = 0.5
}

variable "max_capacity" {
  description = "Maximum Aurora Serverless v2 capacity"
  default     = 4.0
}