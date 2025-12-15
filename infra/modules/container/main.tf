resource "aws_ecr_repository" "ecr" {
  name                 = "three-tier-cr"
  
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_iam_openid_connect_provider" "default" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]
}

resource "aws_security_group" "lb" {
  name        = "backend-lb-sg"
  description = "ALB security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress { # to tasks on container port
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "backend_tg" {
  name        = "backend-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"               # REQUIRED for Fargate

  health_check {
    path                = "/"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb" "backend-lb" {
  name = "backend-lb"
  internal = false
  load_balancer_type = "application"
  subnets = var.public_subnet_ids
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.backend-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}

resource "aws_security_group" "tasks" {
  name   = "backend-tasks-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.lb.id] # only ALB can reach tasks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Execution role: lets the agent pull from ECR + write logs
resource "aws_iam_role" "ecs_execution" {
  name = "ecsExecutionRole-backend"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role" "ecs_task" {
  name = "ecsTaskRole-backend"
  assume_role_policy = aws_iam_role.ecs_execution.assume_role_policy
}

resource "aws_iam_role_policy_attachment" "ecs_exec_attach" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_cluster" "backend-cluster" {
  name = "backend-cluster"
}

# resource "aws_ecs_service" "backend" {
#   name            = "backend"
#   cluster         = aws_ecs_cluster.backend-cluster.id
#   task_definition = aws_ecs_task_definition.backend.arn
#   desired_count   = 2
#   launch_type     = "FARGATE"
#   platform_version = "LATEST"

#   # Required for Fargate: awsvpc networking
#   network_configuration {
#     subnets         = var.private_subnet_ids   # prefer private subnets
#     security_groups = [aws_security_group.tasks.id]
#     assign_public_ip = false                   # true only if using public subnets
#   }

#   load_balancer {
#     target_group_arn = aws_lb_target_group.backend_tg.arn
#     container_name   = "backend"
#     container_port   = 8080
#   }

#   depends_on = [
#     aws_lb_listener.http
#   ]
# }