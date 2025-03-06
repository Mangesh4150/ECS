 resource "aws_security_group" "SG" {
#   name        = "SG"
#   description = "Allow Port 80"
  for_each    = var.sg_names
  name        = "SG-${each.key}"  # Ensure unique names per service
  description = "Security group for ${each.key}"
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

  tags = {
    Name = "SG-${each.key}"
  }
}

resource "aws_ecs_service" "ECS-Service" {
#   name                               = "my-service"
# name            = "my-service-${each.key}" # Ensure unique service names
name            = "my-service-${var.service_name}"
  cluster         = var.cluster_id           # Use the shared cluster ID
  launch_type                        = "FARGATE"
  platform_version                   = "LATEST"
#   cluster                            = aws_ecs_cluster.ECS.id
  task_definition                    = aws_ecs_task_definition.TD.arn
  scheduling_strategy                = "REPLICA"
  desired_count                      = 2
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  depends_on                         = [aws_alb_listener.Listener, aws_iam_role.iam-role]


  load_balancer {
    target_group_arn = aws_lb_target_group.TG.arn
    container_name   = "container"
    container_port   = 80
  }


  network_configuration {
    assign_public_ip = true
    # security_groups  = [aws_security_group.SG.id]
    security_groups = [for sg in aws_security_group.SG : sg.id]
    # subnets          = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
    subnets          = var.subnets  # Using the subnets variable
  }
}

resource "aws_ecs_task_definition" "TD" {
  # family                   = "nginx"
  family                   = "nginx-${var.service_name}"  # Unique family name per service
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.iam-role.arn
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  container_definitions = jsonencode([
    {
      # name      = "main-container"
      name      = "app-${var.service_name}"  # Unique container name per service
      image     = var.image_url
      cpu       = 1024
      memory    = 2048
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_iam_role" "iam-role" {
  name               = "ECS-execution-role"
  assume_role_policy = file("${path.module}/iam-role.json")
}

resource "aws_iam_role_policy" "iam-policy" {
  name   = "ECS-execution-role-policy"
  role   = aws_iam_role.iam-role.id
  policy = file("${path.module}/iam-policy.json")
}

resource "aws_lb" "LB" {
  name               = "LB"
  internal           = false
  load_balancer_type = "application"
  # security_groups    = [aws_security_group.SG.id]
  security_groups = [for sg in aws_security_group.SG : sg.id]
#   subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
subnets          = var.subnets

  tags = {
    Name = "LB"
  }
}

resource "aws_alb_listener" "Listener" {
  load_balancer_arn = aws_lb.LB.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.TG.id
    type             = "forward"
  }
}

resource "aws_lb_target_group" "TG" {
  name        = "TG"
  port        = "80"
  protocol    = "HTTP"
  target_type = "ip"
#   vpc_id      = aws_vpc.vpc.id
    vpc_id      = var.vpc_id

  tags = {
    Name = "TG"
  }
}

#### Define Auto Scaling Target ####
resource "aws_appautoscaling_target" "ecs_target" {
  depends_on         = [aws_ecs_service.ECS-Service] 
  # depends_on         = values(aws_ecs_service.ECS-Service)  # Wait for all ECS services
  max_capacity       = 5  # Maximum number of tasks
  min_capacity       = 2  # Minimum number of tasks
  resource_id        = "service/${var.cluster_id}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}


#### Define Auto Scaling Policies - Scale-Up Policy ####
resource "aws_appautoscaling_policy" "scale_up" {
 
  name               = "scale-up-${var.service_name}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 60.0  # Scale up when CPU > 60%
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

#### Define Auto Scaling Policies - Scale-Down Policy ####
resource "aws_appautoscaling_policy" "scale_down" {
  name               = "scale-down-${var.service_name}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 30.0  # Scale down when CPU < 30%
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}



#### Add CloudWatch Alarms ####
resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "high-cpu-${var.service_name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace          = "AWS/ECS"
  period             = 60
  statistic          = "Average"
  threshold         = 80.0
  alarm_description  = "Alert: CPU utilization is above 80%"
  alarm_actions      = [var.sns_topic_arn]  # SNS topic for notifications
  dimensions = {
    ClusterName = var.cluster_id
    ServiceName = var.service_name
  }
}









































# # ECS Cluster
# resource "aws_ecs_cluster" "main" {
#   name = "my-ecs-cluster"
# }

# # IAM Roles
# resource "aws_iam_role" "ecs_execution_role" {
#   name = "ecs_execution_role"
#   assume_role_policy = jsonencode({
#     Statement = [{
#       Effect = "Allow"
#       Principal = { Service = "ecs-tasks.amazonaws.com" }
#       Action = "sts:AssumeRole"
#     }]
#   })
# }

# resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
#   role       = aws_iam_role.ecs_execution_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }

# # Task Definition
# resource "aws_ecs_task_definition" "app_task" {
#   family                   = "my-app-task"
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   execution_role_arn       = aws_iam_role.ecs_execution_role.arn
#   cpu                      = "256"
#   memory                   = "512"

#   container_definitions = jsonencode([
#     {
#       name      = "my-app"
#       image     = "${aws_ecr_repository.app_repo.repository_url}:latest"
#       cpu       = 256
#       memory    = 512
#       essential = true
#       portMappings = [{
#         containerPort = 80
#         hostPort      = 80
#       }]
#     }
#   ])
# }

# # Security Group
# resource "aws_security_group" "ecs_sg" {
#   name = "ecs_security_group"
# #   vpc_id = "vpc-xxxxxxxx" # Replace with your VPC ID
#   vpc_id = var.vpc_id

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# # ECS Service
# resource "aws_ecs_service" "app_service" {
#   name            = "my-app-service"
#   cluster         = aws_ecs_cluster.main.id
#   task_definition = aws_ecs_task_definition.app_task.arn
#   desired_count   = 1
#   launch_type     = "FARGATE"

#   network_configuration {
#     subnets         = ["subnet-xxxxxxxx"]  # Replace with your subnet IDs
#     security_groups = [aws_security_group.ecs_sg.id]
#     assign_public_ip = true
#   }
# }


# resource "aws_ecs_cluster" "ECS" {
# #   name = "my-cluster"
#     name = var.cluster_name

#   tags = {
#     Name = "my-new-cluster"
#   }
# } 
