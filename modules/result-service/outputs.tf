output "result_url" {
  description = "URL of the result service"
  value       = aws_lb.result.dns_name
}

output "result_target_group_arn" {
  description = "ARN of the result target group"
  value       = aws_lb_target_group.result.arn
}