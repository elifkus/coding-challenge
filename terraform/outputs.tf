
# The load balancer DNS name
output "sentiment_lb_dns_name" {
  value = aws_alb.sentiment_load_balancer.dns_name
}

output "tweetapi_lb_dns_name" {
  value = aws_alb.tweetapi_load_balancer.dns_name
}