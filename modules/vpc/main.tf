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

# Create Firewall Subnet
resource "aws_subnet" "firewall" {
  vpc_id            = aws_vpc.internet.id
  cidr_block        = var.firewall_cidr
  availability_zone = var.az_a

  tags = {
    Name        = "${var.prefix}-firewall-subnet"
    Environment = var.environment
  }
}

# Create Gateway Subnet A
resource "aws_subnet" "gateway_a" {
  vpc_id            = aws_vpc.internet.id
  cidr_block        = var.gateway_a_cidr
  availability_zone = var.az_a

  tags = {
    Name        = "${var.prefix}-gateway-subnet-a"
    Environment = var.environment
  }
}

# Create Gateway Subnet B
resource "aws_subnet" "gateway_b" {
  vpc_id            = aws_vpc.internet.id
  cidr_block        = var.gateway_b_cidr
  availability_zone = var.az_b

  tags = {
    Name        = "${var.prefix}-gateway-subnet-b"
    Environment = var.environment
  }
}

# Create Internet VPC Transit Gateway Subnet
resource "aws_subnet" "internet_tgw" {
  vpc_id            = aws_vpc.internet.id
  cidr_block        = var.internet_tgw_cidr
  availability_zone = var.az_a

  tags = {
    Name        = "${var.prefix}-internet-tgw-subnet"
    Environment = var.environment
  }
}

# -----------------------------------------------------------------------------
# Workload VPC Subnets
# -----------------------------------------------------------------------------

# Create Web Subnet A
resource "aws_subnet" "web_a" {
  vpc_id            = aws_vpc.workload.id
  cidr_block        = var.web_a_cidr
  availability_zone = var.az_a

  tags = {
    Name        = "${var.prefix}-web-subnet-a"
    Environment = var.environment
  }
}

# Create Web Subnet B
resource "aws_subnet" "web_b" {
  vpc_id            = aws_vpc.workload.id
  cidr_block        = var.web_b_cidr
  availability_zone = var.az_b

  tags = {
    Name        = "${var.prefix}-web-subnet-b"
    Environment = var.environment
  }
}

# Create Workload VPC Transit Gateway Subnet
resource "aws_subnet" "workload_tgw" {
  vpc_id            = aws_vpc.workload.id
  cidr_block        = var.workload_tgw_cidr
  availability_zone = var.az_a

  tags = {
    Name        = "${var.prefix}-workload-tgw-subnet"
    Environment = var.environment
  }
}

# Create App Subnet A
resource "aws_subnet" "app_a" {
  vpc_id            = aws_vpc.workload.id
  cidr_block        = var.app_a_cidr
  availability_zone = var.az_a

  tags = {
    Name        = "${var.prefix}-app-subnet-a"
    Environment = var.environment
  }
}

# Create App Subnet B
resource "aws_subnet" "app_b" {
  vpc_id            = aws_vpc.workload.id
  cidr_block        = var.app_b_cidr
  availability_zone = var.az_b

  tags = {
    Name        = "${var.prefix}-app-subnet-b"
    Environment = var.environment
  }
}

# Create Data Subnet A
resource "aws_subnet" "data_a" {
  vpc_id            = aws_vpc.workload.id
  cidr_block        = var.data_a_cidr
  availability_zone = var.az_a

  tags = {
    Name        = "${var.prefix}-data-subnet-a"
    Environment = var.environment
  }
}

# Create Data Subnet B
resource "aws_subnet" "data_b" {
  vpc_id            = aws_vpc.workload.id
  cidr_block        = var.data_b_cidr
  availability_zone = var.az_b

  tags = {
    Name        = "${var.prefix}-data-subnet-b"
    Environment = var.environment
  }
}