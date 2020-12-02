terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = "hivemind"
  region  = var.region
}

resource "aws_ecs_cluster" "hivemind_cluster" {
  name = "hivemind-cluster"
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
  name   = "log-policy"
  role   = aws_iam_role.ecsTaskExecutionRole.name
  policy = data.aws_iam_policy_document.log_policy_doc.json
}

data "aws_iam_policy_document" "log_policy_doc" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions   = ["logs:*"]
  }
}

resource "aws_ecs_task_definition" "sentiment_analysis_task" {
  family                   = "sentiment-analysis-task"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "sentiment-analysis-task",
      "image": "${var.docker_registry}/hivemind/sentiment-analysis:latest",
      "essential": true,
      "portMappings": [
        {
          "containerPort": ${var.sentiment_api_port},
          "hostPort": ${var.sentiment_api_port}
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
      "cpu": 256,
      "environment": [
                {
                    "name": "PORT",
                    "value": "${var.sentiment_api_port}"
                },
                {
                    "name": "HOST",
                    "value": "${var.sentiment_api_ip}"
                }
            ]
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_ecs_service" "sentiment_service" {
  name                              = "sentiment-service"
  cluster                           = aws_ecs_cluster.hivemind_cluster.id
  task_definition                   = aws_ecs_task_definition.sentiment_analysis_task.arn
  launch_type                       = "FARGATE"
  desired_count                     = 3
  health_check_grace_period_seconds = 60

  load_balancer {
    target_group_arn = aws_lb_target_group.sentiment_lb_target_group.arn
    container_name   = aws_ecs_task_definition.sentiment_analysis_task.family
    container_port   = var.sentiment_api_port
  }

  network_configuration {
    subnets = aws_subnet.private_subnets.*.id
    security_groups  = [aws_security_group.sentiment_service_security_group.id]
    assign_public_ip = false
  }

  depends_on = [aws_lb_listener.sentiment_http_forward, aws_iam_role_policy_attachment.ecsTaskExecutionRole_policy]
}

resource "aws_security_group" "sentiment_service_security_group" {
  name   = "sentiment-service-security-group"
  vpc_id = aws_default_vpc.default_vpc.id

  ingress {
    from_port       = var.sentiment_api_port
    to_port         = var.sentiment_api_port
    protocol        = "tcp"
    security_groups = [aws_security_group.sentiment_load_balancer_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "tweet_api_task" {
  family                   = "tweet-api-task"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "tweet-api-task",
      "image": "${var.docker_registry}/hivemind/tweet-api:latest",
      "essential": true,
      "portMappings": [
        {
          "containerPort": ${var.tweet_api_port},
          "hostPort": ${var.tweet_api_port}
        }
      ],
      "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${aws_cloudwatch_log_group.tweetapi_log_group.name}",
                "awslogs-region": "${var.region}",
                "awslogs-stream-prefix": "ecs"
            }
        },
      "memory": 512,
      "cpu": 256,
      "environment": [
                {
                    "name": "PORT",
                    "value": "${var.tweet_api_port}"
                },
                {
                    "name": "SERVICE_URL",
                    "value": "http://${aws_alb.sentiment_load_balancer.dns_name}:${var.sentiment_lb_port}"
                }
            ]
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_ecs_service" "tweetapi_service" {
  name                              = "tweetapi-service"
  cluster                           = aws_ecs_cluster.hivemind_cluster.id
  task_definition                   = aws_ecs_task_definition.tweet_api_task.arn
  launch_type                       = "FARGATE"
  desired_count                     = 3
  health_check_grace_period_seconds = 60

  load_balancer {
    target_group_arn = aws_lb_target_group.tweetapi_lb_target_group.arn
    container_name   = aws_ecs_task_definition.tweet_api_task.family
    container_port   = var.tweet_api_port
  }

  network_configuration {
    subnets = aws_subnet.private_subnets.*.id
    security_groups  = [aws_security_group.tweetapi_service_security_group.id]
    assign_public_ip = false
  }

  depends_on = [aws_lb_listener.tweetapi_http_forward, aws_iam_role_policy_attachment.ecsTaskExecutionRole_policy]
}

resource "aws_security_group" "tweetapi_service_security_group" {
  name   = "tweetapi-service-security-group"
  vpc_id = aws_default_vpc.default_vpc.id

  ingress {
    from_port       = var.tweet_api_port
    to_port         = var.tweet_api_port
    protocol        = "tcp"
    security_groups = [aws_security_group.tweetapi_load_balancer_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "tweetui_task" {
  family                   = "tweetui-task"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "tweetui-task",
      "image": "${var.docker_registry}/hivemind/tweet-ui:latest",
      "essential": true,
      "portMappings": [
        {
          "containerPort": ${var.tweet_ui_port},
          "hostPort": ${var.tweet_ui_port}
        }
      ],
      "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${aws_cloudwatch_log_group.tweetui_log_group.name}",
                "awslogs-region": "${var.region}",
                "awslogs-stream-prefix": "ecs"
            }
        },
      "memory": 512,
      "cpu": 256,
      "environment": []
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_ecs_service" "tweetui_service" {
  name                              = "tweetui-service"
  cluster                           = aws_ecs_cluster.hivemind_cluster.id
  task_definition                   = aws_ecs_task_definition.tweetui_task.arn
  launch_type                       = "FARGATE"
  desired_count                     = 3
  health_check_grace_period_seconds = 60

  load_balancer {
    target_group_arn = aws_lb_target_group.tweetui_lb_target_group.arn
    container_name   = aws_ecs_task_definition.tweetui_task.family
    container_port   = var.tweet_ui_port
  }

  network_configuration {
    subnets = aws_subnet.private_subnets.*.id
    security_groups  = [aws_security_group.tweetui_service_security_group.id]
    assign_public_ip = false
  }

  depends_on = [aws_lb_listener.tweetapi_http_forward, aws_iam_role_policy_attachment.ecsTaskExecutionRole_policy]
}

resource "aws_security_group" "tweetui_service_security_group" {
  name   = "tweetui-service-security-group"
  vpc_id = aws_default_vpc.default_vpc.id

  ingress {
    from_port       = var.tweet_ui_port
    to_port         = var.tweet_ui_port
    protocol        = "tcp"
    security_groups = [aws_security_group.tweetapi_load_balancer_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



