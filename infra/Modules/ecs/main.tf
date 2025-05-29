resource "aws_ecs_cluster" "main" {
  name = var.cluster_name
}

resource "aws_lb" "main" {
  name               = "${var.cluster_name}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.alb_subnets
  security_groups = [
    aws_security_group.alb_sg.id
  ]
}

resource "aws_security_group" "alb_sg" {
  name        = "${var.cluster_name}-alb-sg"
  description = "Allow HTTP"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_lb_target_group" "services" {
  for_each = { for c in var.container_definitions : c.name => c }

  name        = "${each.value.name}-tg"
  port        = each.value.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {

      content_type = "text/plain"
      message_body = "Service not found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "services" {
  for_each = { for c in var.container_definitions : c.name => c }

  listener_arn = aws_lb_listener.http.arn
  priority     = 100 + index(var.container_definitions[*].name, each.value.name)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.services[each.key].arn
  }

  condition {
    path_pattern {
      values = [each.value.path]
    }
  }

}

resource "aws_ecs_task_definition" "services" {
  for_each = { for c in var.container_definitions : c.name => c }

  family                   = each.value.name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_exec.arn
  container_definitions    = jsonencode([{
    name      = each.value.name
    image     = each.value.image
    portMappings = [{
      containerPort = each.value.container_port
      protocol      = "tcp"
    }]
  }])
}

resource "aws_ecs_service" "services" {
  for_each = aws_ecs_task_definition.services

  name            = each.key

  cluster         = aws_ecs_cluster.main.id
  launch_type     = "FARGATE"
  desired_count   = 1
  task_definition = each.value.arn

  network_configuration {
    subnets         = var.service_subnets
    assign_public_ip = false
    security_groups = [aws_security_group.ecs_service.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.services[each.key].arn
    container_name   = each.key
    container_port   = var.container_definitions[index(var.container_definitions[*].name, each.key)].container_port
  }

  depends_on = [aws_lb_listener_rule.services]
}

resource "aws_security_group" "ecs_service" {
  name        = "${var.cluster_name}-ecs-sg"
  description = "Allow ECS service access"
  vpc_id      = var.vpc_id


  ingress {
    from_port   = 3000
    to_port     = 3001
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ecs_task_exec" {
  name = "${var.cluster_name}-ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_policy" {
  role       = aws_iam_role.ecs_task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}