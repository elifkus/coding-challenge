resource "aws_alb" "sentiment_load_balancer" {
  name               = "sentiment-load-balancer"
  load_balancer_type = "application"
  idle_timeout       = 600
  subnets = aws_subnet.private_subnets.*.id
  internal = true
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