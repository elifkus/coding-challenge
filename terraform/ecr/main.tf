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
  region  = "eu-central-1"
}

resource "aws_ecr_repository" "sentiment-analysis-repo" {
  name = "hivemind/sentiment-analysis" 
}

resource "aws_ecr_repository" "tweet-api-repo" {
  name = "hivemind/tweet-api" 
}

resource "aws_ecr_repository" "tweet-ui-repo" {
  name = "hivemind/tweet-ui" 
}