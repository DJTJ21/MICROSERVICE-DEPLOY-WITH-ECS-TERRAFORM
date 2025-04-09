variable "deployment_name" {
  description = "Prefix for all resources"
  type        = string
  default     = "microservices"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}



variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "database_type" {
  description = "Type of database (mysql or postgresql)"
  type        = string
  default     = "mysql"
  validation {
    condition     = contains(["mysql", "postgresql"], var.database_type)
    error_message = "Database type must be either 'mysql' or 'postgresql'."
  }
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "voting_user"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}


variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {
    Project     = "Microservices"
    Environment = "Production"
    Terraform   = "true"
  }
}


variable "route53_zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
  default     = ""
}

variable "worker_image" {
  type        = string
  description = "Image worker name"
  default     = "public.ecr.aws/i4l0v2l9/worker-service:latest"
}


variable "db_name" {
  type       = string
  description = "Nom de la base de donnee"
  default     = "votingDB"
}
variable "vote_image" {
  type        = string
  description = "image url"
  default     = "public.ecr.aws/i4l0v2l9/vote-service:v1"
}

variable "vote_port" {
  type        = number
  description =  "port du service de vote"
  default     = 80
}

variable "result_image" {
  type = string
  default = "public.ecr.aws/i4l0v2l9/result-service:latest"

}

variable "result_port" {
  type        = number
  description = "port du service result"
  default     = 80
}

variable "domain_name-vote" {
  type        = string
  description = "domain name for vote service"
  default     = "vote.azopat.cm"
}

variable "cdn_name-vote" {
  type        = string
  description = ""
  default = "vote-cdn"
}

variable "web-acl-name-vote" {
  type       = string
  description = ""
  default = "vote-waf"
}


variable "domain_name-result" {
  type        = string
  description = "domain name for result"
  default     = "result.azopat.cm"
}

variable "cdn_name-result" {
  type        = string
  description = ""
  default     = "result-cdn"
}

variable "web-acl-name-result" {
  type        = string
  description = ""
  default     = "result-waf"
}

variable "root-domain"{
  type         = string
  default      = "azopat.cm"
}
