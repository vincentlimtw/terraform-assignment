variable "prefix" { description = "Resource Name Prefix" }
variable "environment" { description = "Environment name" }
variable "internet_vpc_id" { description = "Internet VPC ID" }
variable "workload_vpc_id" { description = "Workload VPC ID" }
variable "internet_tgw_id" { description = "Internet TGW Subnet ID" }
variable "workload_tgw_id" { description = "Workload TGW Subnet ID" }
variable "internet_vpc_cidr" { description = "Internet VPC CIDR for TGW route" }
variable "workload_vpc_cidr" { description = "Workload VPC CIDR for TGW route" }
