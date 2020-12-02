variable "region" {
  default = "eu-central-1"
}

variable "docker_registry" {
  default = "<docker_registry>"
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

variable "tweet_ui_port" {
  default = "9000"
}

variable "tweetui_lb_port" {
  default = "80"
}
