
# The load balancer DNS name
output "lb_dns" {
  value = aws_alb.sentiment_load_balancer.dns_name
}