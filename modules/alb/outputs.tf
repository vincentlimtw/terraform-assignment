output "workload_alb_tg_arn" { value = aws_lb_target_group.workload_alb.arn }
output "app_url" { value = "http://${aws_lb.internet_alb.dns_name}" }