output "redis_endpoint" {
  description = "Endpoint of the Redis cluster"
  value       = aws_elasticache_cluster.main.cache_nodes[0].address
}