# -----------------------------------------------------------------------------
# Route Tables
# -----------------------------------------------------------------------------

# Create Gateway Route Table
resource "aws_route_table" "gateway" {
  vpc_id = var.internet_vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }

  route {
    cidr_block         = var.workload_vpc_cidr
    transit_gateway_id = var.tgw_id
  }

  tags = {
    Name        = "${var.prefix}-gateway-rt"
    Environment = var.environment
  }

  depends_on = [var.internet_tgw_attachment_id,
  var.workload_tgw_attachment_id]
}

# Create Gateway Route Table Association for Gateway Subnet A
resource "aws_route_table_association" "gateway_a" {
  route_table_id = aws_route_table.gateway.id
  subnet_id      = var.gateway_a_id
}

# Create Gateway Route Table Association for Gateway Subnet B
resource "aws_route_table_association" "gateway_b" {
  route_table_id = aws_route_table.gateway.id
  subnet_id      = var.gateway_b_id
}

# Create NAT Gateway Route Table
resource "aws_route_table" "nat_gateway" {
  vpc_id = var.internet_vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.nat_gateway_id
  }

  tags = {
    Name        = "${var.prefix}-nat-gateway-rt"
    Environment = var.environment
  }
}

# Create NAT Gateway Route Table Association for Internet TGW Subnet
resource "aws_route_table_association" "internet_tgw" {
  route_table_id = aws_route_table.nat_gateway.id
  subnet_id      = var.internet_tgw_id
}

# Create Web Route Table
resource "aws_route_table" "web" {
  vpc_id = var.workload_vpc_id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = var.tgw_id
  }

  tags = {
    Name        = "${var.prefix}-web-rt"
    Environment = var.environment
  }

  depends_on = [var.internet_tgw_attachment_id,
  var.workload_tgw_attachment_id]
}

# Create Web Route Table Association for Web Subnet A
resource "aws_route_table_association" "web_a" {
  route_table_id = aws_route_table.web.id
  subnet_id      = var.web_a_id
}

# Create Web Route Table Association for Web Subnet B
resource "aws_route_table_association" "web_b" {
  route_table_id = aws_route_table.web.id
  subnet_id      = var.web_b_id
}

# Create App Route Table
resource "aws_route_table" "app" {
  vpc_id = var.workload_vpc_id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = var.tgw_id
  }

  tags = {
    Name        = "${var.prefix}-app-rt"
    Environment = var.environment
  }

  depends_on = [var.internet_tgw_attachment_id,
  var.workload_tgw_attachment_id]
}

# Create App Route Table Association for App Subnet A
resource "aws_route_table_association" "app_a" {
  route_table_id = aws_route_table.app.id
  subnet_id      = var.app_a_id
}

# Create App Route Table Association for App Subnet B
resource "aws_route_table_association" "app_b" {
  route_table_id = aws_route_table.app.id
  subnet_id      = var.app_b_id
}