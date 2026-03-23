output "internet_vpc_id" { value = aws_vpc.internet.id }
output "workload_vpc_id"  { value = aws_vpc.workload.id }
output "internet_tgw_id"  { value = aws_subnet.internet_tgw.id }
output "workload_tgw_id"  { value = aws_subnet.workload_tgw.id }