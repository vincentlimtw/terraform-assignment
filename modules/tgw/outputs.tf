output "tgw_id" { value = aws_ec2_transit_gateway.main.id }
output "internet_tgw_attachment_id" { value = aws_ec2_transit_gateway_vpc_attachment.internet.id }
output "workload_tgw_attachment_id" { value = aws_ec2_transit_gateway_vpc_attachment.workload.id }