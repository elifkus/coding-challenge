output "tweetapi_lb_dns_name" {
  value = aws_alb.tweetapi_load_balancer.dns_name
}