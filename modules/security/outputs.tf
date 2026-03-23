output "internet_alb_sg_id" { value = aws_security_group.internet_alb.id }
output "workload_alb_sg_id" { value = aws_security_group.workload_alb.id }
output "ecs_sg_id" { value = aws_security_group.ecs.id }