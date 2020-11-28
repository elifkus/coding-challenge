variable "region" {
  default = "eu-central-1"
}

variable "docker_registry" {
  default = "401172141612.dkr.ecr.eu-central-1.amazonaws.com"
}

variable "sentiment_api_port" {
  default = "9000"
}

variable "sentiment_api_ip" {
  default = "0.0.0.0"
}

variable "sentiment_lb_port" {
  default = "80"
}

variable "tweet_api_port" {
  default = "8080"
}

variable "tweetapi_lb_port" {
  default = "80"
}
