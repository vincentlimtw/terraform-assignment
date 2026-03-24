variable "prefix" { description = "Resource Name Prefix" }
variable "environment" { description = "Environment name" }
variable "internet_vpc_cidr" { description = "Internet VPC CIDR" }
variable "workload_vpc_cidr" { description = "Workload VPC CIDR" }
variable "internet_subnets" {
  description = "Map of Internet VPC subnets"
  type = map(object({
    cidr = string
    az   = string
  }))
}
variable "workload_subnets" {
  description = "Map of Workload VPC subnets"
  type = map(object({
    cidr = string
    az   = string
  }))
}