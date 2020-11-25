terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.region
}

resource "aws_ecs_cluster" "hivemind-cluster" {
    name = "hivemind-cluster"
}

resource "aws_ecs_task_definition" "sentiment_analysis_task" {
  family                   = "sentiment-analysis-task" 
  container_definitions    = <<DEFINITION
  [
    {
      "name": "sentiment-analysis-task",
      "image": "${var.docker_registry}/sentiment-analysis:latest",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 9000,
          "hostPort": 9000
        }
      ],
      "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${aws_cloudwatch_log_group.sentiment_log_group.name}",
                "awslogs-region": "${var.region}",
                "awslogs-stream-prefix": "ecs"
            }
        },
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] 
  network_mode             = "awsvpc"    
  memory                   = 512         
  cpu                      = 256         
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json 
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "log_policy" {
  name        = "log-policy"
  role = aws_iam_role.ecsTaskExecutionRole.name
  policy      = data.aws_iam_policy_document.log_policy_doc.json 
}

data "aws_iam_policy_document" "log_policy_doc" {
  statement {
    effect = "Allow"
    resources = [ "*" ]
    actions = ["logs:*"]
  }
}

resource "aws_ecs_service" "sentiment_service" {
  name            = "sentiment-service" 
  cluster         = aws_ecs_cluster.hivemind-cluster.id 
  task_definition = aws_ecs_task_definition.sentiment_analysis_task.arn
  launch_type     = "FARGATE"
  desired_count   = 3
  health_check_grace_period_seconds = 60 

   load_balancer {
    target_group_arn = aws_lb_target_group.sentiment_lb_target_group.arn
    container_name   = aws_ecs_task_definition.sentiment_analysis_task.family
    container_port   = 9000 
  }

  network_configuration {
    subnets          = [aws_default_subnet.default_subnet_a.id, aws_default_subnet.default_subnet_b.id, aws_default_subnet.default_subnet_c.id]
    assign_public_ip = true 
    security_groups = [ aws_security_group.service_security_group.id ]
  }

   depends_on = [aws_lb_listener.http_forward, aws_iam_role_policy_attachment.ecsTaskExecutionRole_policy]

}

resource "aws_security_group" "service_security_group" {
  name = "service-security-group"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    from_port = 9000
    to_port   = 9000
    protocol  = "tcp"
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  egress {
    from_port   = 0 
    to_port     = 0 
    protocol    = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 
  }
}

resource "aws_default_vpc" "default_vpc" {
}

resource "aws_default_subnet" "default_subnet_a" {
  availability_zone = "eu-central-1a"
}

resource "aws_default_subnet" "default_subnet_b" {
  availability_zone = "eu-central-1b"
}

resource "aws_default_subnet" "default_subnet_c" {
  availability_zone = "eu-central-1c"
}

resource "aws_eip" "sentiment_lb_ip" {
  vpc      = true
}

resource "aws_alb" "sentiment_load_balancer" {
  name               = "sentiment-load-balancer" 
  load_balancer_type = "application"
  idle_timeout = 600
  subnets = [ 
    aws_default_subnet.default_subnet_a.id,
    aws_default_subnet.default_subnet_b.id,
    aws_default_subnet.default_subnet_c.id
  ]
   security_groups = [aws_security_group.load_balancer_security_group.id]
}

resource "aws_security_group" "load_balancer_security_group" {
  vpc_id      = aws_default_vpc.default_vpc.id
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

resource "aws_lb_target_group" "sentiment_lb_target_group" {
  name        = "sentiment-lb-target-group"
  port        = 9000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default_vpc.id
  lifecycle {
        create_before_destroy = true
  }
  health_check {
    timeout = "20"  
    matcher = "200,301,302"
    path = "/"
    port = "9000"
    protocol = "HTTP"
    interval = "60"
    unhealthy_threshold = "3"
  }
}

resource "aws_lb_listener" "http_forward" {
  load_balancer_arn = aws_alb.sentiment_load_balancer.arn 
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sentiment_lb_target_group.arn
  }
}

resource "aws_cloudwatch_log_group" "sentiment_log_group" {
  name              = "/ecs/sentiment-log-group"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_stream" "sentiment_log_stream" {
  name           = "sentiment-log-stream"
  log_group_name = aws_cloudwatch_log_group.sentiment_log_group.name
}




