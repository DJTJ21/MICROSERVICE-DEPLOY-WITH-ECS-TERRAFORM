resource "aws_ecs_cluster" "vote" {
  name = "${var.deployment_name}-vote-cluster"
  tags = var.tags
}

resource "aws_cloudwatch_log_group" "vote" {
  name = "/ecs/${var.deployment_name}-vote"
  tags = var.tags
}

locals {
  vote_env = [
   #  { name = "REDIS_HOST" , value = var.redis_endpoint},
     { name = "REDIS_HOST", value = split(":", var.redis_endpoint)[0] },
     { name = "REDIS_PORT", value = "6379" }
  ]
}

resource "aws_ecs_task_definition" "vote" {
  family                   = "${var.deployment_name}-vote"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "vote"
      image     = var.image_url
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]
      environment = local.vote_env 
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.vote.name
          awslogs-region       = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = var.tags
}

resource "aws_lb" "vote" {
  name               = "${var.deployment_name}-vote-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  tags = var.tags
}

resource "aws_lb_target_group" "vote" {
  name        = "${var.deployment_name}-vote-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

   health_check {
    path                = "/"                 
    interval            = 30                  
    timeout             = 5                  
    healthy_threshold   = 3                   
    unhealthy_threshold = 3                   
    matcher             = "200-499"          
  }

  tags = var.tags
}

resource "aws_lb_listener" "vote" {
  load_balancer_arn = aws_lb.vote.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vote.arn
  }

  tags = var.tags
}

resource "aws_ecs_service" "vote" {
  name            = "${var.deployment_name}-vote"
  cluster         = aws_ecs_cluster.vote.id
  task_definition = aws_ecs_task_definition.vote.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.vote.arn
    container_name   = "vote"
    container_port   = var.container_port
  }

  tags = var.tags
}

/* resource "aws_security_group_rule" "alb_to_vote" {
  type              = "ingress"
  from_port         = var.container_port  
  to_port           = var.container_port
  protocol          = "tcp"
  security_group_id = var.ecs_security_group_id
  source_security_group_id = var.alb_security_group_id
}
*/