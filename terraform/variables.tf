variable "region" {
  default = "eu-central-1"
}

variable "docker_registry" {
  default = "401172141612.dkr.ecr.us-west-2.amazonaws.com"
}

variable "sentiment_api_port" {
  default = "9000"
}

variable "sentiment_api_ip" {
  default = "0.0.0.0"
}
