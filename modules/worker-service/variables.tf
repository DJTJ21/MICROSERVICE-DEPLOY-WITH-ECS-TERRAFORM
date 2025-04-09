# modules/ecs-service/variables.tf
variable "redis_endpoint" {
  type        = string
  description = "Endpoint de la base de données redis"
}

variable "db_endpoint" {
  type        = string
  description = "Endpoint de la base de données RDS"
}

variable "db_username" {
  type        = string
  sensitive   = true
  description = "Nom d'utilisateur de la base de données"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Mot de passe de la base de données"
}

variable "db_name" {
  type        = string
  description = "Nom de la base de données"
}

variable "image_url" {
  type        = string
  description = "URL de l'image Docker"
}

variable "task_cpu" {
  type        = number
  default     = 256
  description = "CPU alloué (unités AWS)"
}

variable "task_memory" {
  type        = number
  default     = 512
  description = "Mémoire allouée (MB)"
}

variable "deployment_name" {
  description = "Prefix for all resources"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}
variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "ECS security group ID"
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "ECS task execution role ARN"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  
}
