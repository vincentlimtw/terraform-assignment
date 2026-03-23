# -----------------------------------------------------------------------------
# NAT Gateway
# -----------------------------------------------------------------------------

# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name        = "${var.prefix}-nat-eip"
    Environment = var.environment
  }
}

# Create NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = var.gateway_a

  tags = {
    Name        = "${var.prefix}-main-nat"
    Environment = var.environment
  }
}