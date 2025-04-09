module "networking" {
  source              = "./modules/networking"
  deployment_name     = var.deployment_name
  vpc_cidr            = "10.0.0.0/16"
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  availability_zones   = var.availability_zones
  tags                = var.tags
}

module "iam" {
  source          = "./modules/iam"
  deployment_name = var.deployment_name
  tags           = var.tags
}


module "database" {
  source              = "./modules/database"
  deployment_name     = var.deployment_name
  database_type       = var.database_type
  db_username         = var.db_username
  db_password         = var.db_password
  db_name             = var.db_name
  private_subnet_ids  = module.networking.private_subnet_ids
  security_group_id   = module.networking.rds_security_group_id
  tags                = var.tags
}

module "redis" {
  source              = "./modules/redis"
  deployment_name     = var.deployment_name
  private_subnet_ids  = module.networking.private_subnet_ids
  security_group_id   = module.networking.redis_security_group_id
  tags                = var.tags
}



module "worker" {
  source                     = "./modules/worker-service"
  deployment_name            = var.deployment_name
  region                     = var.region
  db_endpoint                = module.database.db_endpoint
  db_username                = var.db_username
  db_password                = var.db_password
  private_subnet_ids         = module.networking.private_subnet_ids
  public_subnet_ids          = module.networking.public_subnet_ids
  ecs_security_group_id      = module.networking.ecs_security_group_id
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  vpc_id                     = module.networking.vpc_id
  tags                       = var.tags
  redis_endpoint             = module.redis.redis_endpoint
  image_url                  = var.worker_image
  db_name                    = var.db_name

   depends_on = [ module.database, module.redis]
}


module "result" {
  source                     = "./modules/result-service"
  deployment_name            = var.deployment_name
  region                     = var.region
  db_endpoint                = module.database.db_endpoint
  db_username                = var.db_username
  db_password                = var.db_password
  private_subnet_ids         = module.networking.private_subnet_ids
  public_subnet_ids          = module.networking.public_subnet_ids
  ecs_security_group_id      = module.networking.ecs_security_group_id
  alb_security_group_id      = module.networking.alb_security_group_id
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  vpc_id                     = module.networking.vpc_id
  tags                       = var.tags
  image_url                  = var.result_image
  container_port             = var.result_port
  db_name                    = var.db_name

   depends_on = [ module.database]
}


module "vote" {
  source                     = "./modules/vote-service"
  deployment_name            = var.deployment_name
  region                     = var.region
  private_subnet_ids         = module.networking.private_subnet_ids
  public_subnet_ids          = module.networking.public_subnet_ids
  ecs_security_group_id      = module.networking.ecs_security_group_id
  alb_security_group_id      = module.networking.alb_security_group_id
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  vpc_id                     = module.networking.vpc_id
  tags                       = var.tags
  redis_endpoint             = module.redis.redis_endpoint
  image_url                  = var.vote_image
  container_port             = var.vote_port
  

   depends_on = [ module.redis]
}

module "route53-vote" {
  source = "./modules/aws-waf-cdn-acm-route53"
  domain-name  = var.domain_name-vote
  cdn-name     = var.cdn_name-vote
  deployment_name = var.deployment_name
  web_acl_name = var.web-acl-name-vote
  alb          =  "${var.deployment_name}-vote-lb"
  root-domain  =  var.root-domain

  depends_on = [ module.vote ]
}

module "route53-result" {
  source = "./modules/aws-waf-cdn-acm-route53"
  domain-name  = var.domain_name-result
  cdn-name     = var.cdn_name-result
  deployment_name = var.deployment_name
  web_acl_name = var.web-acl-name-result
  alb          =  "${var.deployment_name}-result-lb"
  root-domain  =  var.root-domain

  depends_on = [ module.result ]
}
