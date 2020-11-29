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
  cluster                           = aws_ecs_cluster.hivemind-cluster.id
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
    subnets = aws_default_subnet.default_subnets.*.id
    security_groups  = [aws_security_group.sentiment_service_security_group.id]
    assign_public_ip = true
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
  cluster                           = aws_ecs_cluster.hivemind-cluster.id
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
    subnets = aws_default_subnet.default_subnets.*.id
    security_groups  = [aws_security_group.tweetapi_service_security_group.id]
    assign_public_ip = true
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

resource "aws_default_vpc" "default_vpc" {
}

#terraform import aws_internet_gateway.default_vpc_igw igw-36ee5f5d
resource "aws_internet_gateway" "default_vpc_igw" {
  vpc_id = aws_default_vpc.default_vpc.id
}

resource "aws_default_subnet" "default_subnets" {
  availability_zone = element(["eu-central-1a", "eu-central-1b", "eu-central-1c"], count.index)
  count             = 3
  tags = {
    "Name" = "Public subnet ${count.index}"
  }
}

resource "aws_subnet" "private_subnets" {
  vpc_id            = aws_default_vpc.default_vpc.id
  cidr_block        = element(["172.31.48.0/20", "172.31.64.0/20", "172.31.80.0/20"], count.index)
  availability_zone = element(["eu-central-1a", "eu-central-1b", "eu-central-1c"], count.index)
  count             = 3
  tags = {
    "Name" = "Private subnet ${count.index}"
  }
}

resource "aws_nat_gateway" "main_nats" {
  count         = length(aws_subnet.private_subnets)
  allocation_id = element(aws_eip.nat_ips.*.id, count.index)
  subnet_id     = element(aws_subnet.private_subnets.*.id, count.index)
  depends_on    = [aws_internet_gateway.default_vpc_igw]
}
 
resource "aws_eip" "nat_ips" {
  count = length(aws_subnet.private_subnets)
  vpc = true
}

resource "aws_route_table" "private_subnets_route_table" {
  count  = length(aws_subnet.private_subnets)
  vpc_id = aws_default_vpc.default_vpc.id
}

resource "aws_route" "private_subnets_routes" {
  count                  = length(aws_subnet.private_subnets)
  route_table_id         = element(aws_route_table.private_subnets_route_table.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.main_nats.*.id, count.index)
}
 
resource "aws_route_table_association" "private_subnet_route_table_assc" {
  count          = length(aws_subnet.private_subnets)
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id = element(aws_route_table.private_subnets_route_table.*.id, count.index)
}

resource "aws_alb" "sentiment_load_balancer" {
  name               = "sentiment-load-balancer"
  load_balancer_type = "application"
  idle_timeout       = 600
  subnets = aws_default_subnet.default_subnets.*.id
  security_groups = [aws_security_group.sentiment_load_balancer_security_group.id]
}

resource "aws_security_group" "sentiment_load_balancer_security_group" {
  vpc_id = aws_default_vpc.default_vpc.id
  ingress {
    from_port   = var.sentiment_lb_port
    to_port     = var.sentiment_lb_port
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
  port        = var.sentiment_api_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default_vpc.id
  lifecycle {
    create_before_destroy = true
  }
  health_check {
    timeout             = "20"
    matcher             = "200,301,302"
    path                = "/"
    port                = var.sentiment_api_port
    protocol            = "HTTP"
    interval            = "60"
    unhealthy_threshold = "3"
  }
}

resource "aws_lb_listener" "sentiment_http_forward" {
  load_balancer_arn = aws_alb.sentiment_load_balancer.arn
  port              = var.sentiment_lb_port
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sentiment_lb_target_group.arn
  }
}

resource "aws_alb" "tweetapi_load_balancer" {
  name               = "tweet-api"
  load_balancer_type = "application"
  idle_timeout       = 600
  subnets = aws_default_subnet.default_subnets.*.id
  security_groups = [aws_security_group.tweetapi_load_balancer_security_group.id]
}

resource "aws_security_group" "tweetapi_load_balancer_security_group" {
  vpc_id = aws_default_vpc.default_vpc.id
  ingress {
    from_port   = var.tweetapi_lb_port
    to_port     = var.tweetapi_lb_port
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

resource "aws_lb_target_group" "tweetapi_lb_target_group" {
  name        = "tweetapi-lb-target-group2"
  port        = var.tweet_api_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default_vpc.id
  lifecycle {
    create_before_destroy = true
  }
  health_check {
    timeout             = "20"
    matcher             = "200,301,302"
    path                = "/"
    port                = var.tweet_api_port
    protocol            = "HTTP"
    interval            = "60"
    unhealthy_threshold = "3"
  }
}

resource "aws_lb_listener" "tweetapi_http_forward" {
  load_balancer_arn = aws_alb.tweetapi_load_balancer.arn
  port              = var.tweetapi_lb_port
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tweetapi_lb_target_group.arn
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

resource "aws_cloudwatch_log_group" "tweetapi_log_group" {
  name              = "/ecs/tweetapi-log-group"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_stream" "tweetapi_log_stream" {
  name           = "tweetapi-log-stream"
  log_group_name = aws_cloudwatch_log_group.tweetapi_log_group.name
}






