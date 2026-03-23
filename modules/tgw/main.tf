# -----------------------------------------------------------------------------
# Transit Gateway
# -----------------------------------------------------------------------------

# Create Transit Gateway
resource "aws_ec2_transit_gateway" "main" {
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  tags = {
    Name        = "${var.prefix}-main-tgw"
    Environment = var.environment
  }
}

# Create TGW Attachment to Internet VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "internet" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = var.internet_vpc_id
  subnet_ids         = [var.internet_tgw_id]

  tags = {
    Name        = "${var.prefix}-internet-tgw-attachment"
    Environment = var.environment
  }
}

# Create TGW Attachment to Workload VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "workload" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = var.workload_vpc_id
  subnet_ids         = [var.workload_tgw_id]

  tags = {
    Name        = "${var.prefix}-workload-tgw-attachment"
    Environment = var.environment
  }
}

# Create TGW Route Table
resource "aws_ec2_transit_gateway_route_table" "main" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = {
    Name        = "${var.prefix}-tgw-rt"
    Environment = var.environment
  }
}

# Create TGW Route Table Association for Internet Attachment
resource "aws_ec2_transit_gateway_route_table_association" "internet" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.internet.id
}

# Create TGW Route Table Association for Workload Attachment
resource "aws_ec2_transit_gateway_route_table_association" "workload" {
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.workload.id
}

# Create traffic route to Internet VPC
resource "aws_ec2_transit_gateway_route" "workload_to_internet_vpc" {
  destination_cidr_block         = var.internet_vpc_cidr
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.internet.id
}

# Create public internet traffic route to NAT via Internet VPC
resource "aws_ec2_transit_gateway_route" "workload_to_public_internet" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.internet.id
}

# Create traffic route to Workload VPC
resource "aws_ec2_transit_gateway_route" "internet_to_workload_vpc" {
  destination_cidr_block         = var.workload_vpc_cidr
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.workload.id
}