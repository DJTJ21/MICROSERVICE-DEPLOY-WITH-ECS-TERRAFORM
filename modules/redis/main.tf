resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.deployment_name}-cache-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags       = var.tags
}

resource "aws_elasticache_cluster" "main" {
  cluster_id           = "${var.deployment_name}-cache"
  engine              = "redis"
  node_type           = "cache.t3.micro"
  num_cache_nodes     = 1
  parameter_group_name = "default.redis6.x"
  engine_version      = "6.x"
  port                = 6379
  security_group_ids  = [var.security_group_id]
  subnet_group_name   = aws_elasticache_subnet_group.main.name
  tags                = var.tags
}