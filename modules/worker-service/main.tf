resource "aws_ecs_cluster" "worker" {
  name = "${var.deployment_name}-worker-cluster"
  tags = var.tags
}

resource "aws_cloudwatch_log_group" "worker" {
  name = "/ecs/${var.deployment_name}-worker"
  tags = var.tags
}

locals {
  worker_env = [
      { name = "DB_USER", value = var.db_username },
      { name = "DB_PASSWORD", value = var.db_password },
      { name = "DB_NAME", value = var.db_name },
    #  { name = "REDIS_HOST" , value = var.redis_endpoint},
      { name = "REDIS_HOST", value = split(":", var.redis_endpoint)[0] },
      { name = "DB_HOST", value = split(":", var.db_endpoint)[0] },
      { name = "DB_PORT", value = "5432" },
      { name = "REDIS_PORT", value = "6379" }

  ]
}

resource "aws_ecs_task_definition" "worker" {
  family                   = "${var.deployment_name}-worker"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "worker"
      image     = var.image_url
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
        #  containerPort = var.container_port
        #  hostPort      = var.container_port
        }
      ]
      environment = local.worker_env 
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.worker.name
          awslogs-region       = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = var.tags
}

/*resource "aws_lb" "worker" {
  name               = "${var.deployment_name}-worker-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  tags = var.tags
}
*/

/* resource "aws_lb_target_group" "worker" {
  name        = "${var.deployment_name}-worker-tg"
 # port        = var.container_port
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

resource "aws_lb_listener" "worker" {
  load_balancer_arn = aws_lb.worker.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.worker.arn
  }

  tags = var.tags
}
*/

resource "aws_ecs_service" "worker" {
  name            = "${var.deployment_name}-worker"
  cluster         = aws_ecs_cluster.worker.id
  task_definition = aws_ecs_task_definition.worker.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

 /* load_balancer {
    target_group_arn = aws_lb_target_group.worker.arn
    container_name   = "worker"
    container_port   = var.container_port
  }
  */

  tags = var.tags
}

/*resource "aws_security_group_rule" "alb_to_worker" {
  type              = "ingress"
  from_port         = var.container_port  
  to_port           = var.container_port
  protocol          = "tcp"
  security_group_id = var.ecs_security_group_id
  source_security_group_id = var.alb_security_group_id
}
*/