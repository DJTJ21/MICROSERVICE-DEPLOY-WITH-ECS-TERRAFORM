output "vote_url" {
  description = "URL of the vote service"
  value       = aws_lb.vote.dns_name
}

output "vote_target_group_arn" {
  description = "ARN of the vote target group"
  value       = aws_lb_target_group.vote.arn
}