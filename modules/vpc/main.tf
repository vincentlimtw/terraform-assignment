# -----------------------------------------------------------------------------
# VPC
# -----------------------------------------------------------------------------

# Create Internet VPC
resource "aws_vpc" "internet" {
  cidr_block           = var.internet_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.prefix}-internet-vpc"
    Environment = var.environment
  }
}

# Create Workload VPC
resource "aws_vpc" "workload" {
  cidr_block           = var.workload_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.prefix}-workload-vpc"
    Environment = var.environment
  }
}

# -----------------------------------------------------------------------------
# Internet Gateway
# -----------------------------------------------------------------------------

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.internet.id

  tags = {
    Name        = "${var.prefix}-main-igw"
    Environment = var.environment
  }
}

# -----------------------------------------------------------------------------
# Internet VPC Subnets
# -----------------------------------------------------------------------------

# Create Internet VPC Subnets
resource "aws_subnet" "internet" {
  for_each = var.internet_subnets

  vpc_id            = aws_vpc.internet.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name        = "${var.prefix}-${each.key}-subnet"
    Environment = var.environment
  }
}

# -----------------------------------------------------------------------------
# Workload VPC Subnets
# -----------------------------------------------------------------------------

# Create Workload VPC Subnets
resource "aws_subnet" "workload" {
  for_each = var.workload_subnets

  vpc_id            = aws_vpc.workload.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name        = "${var.prefix}-${each.key}-subnet"
    Environment = var.environment
  }
}