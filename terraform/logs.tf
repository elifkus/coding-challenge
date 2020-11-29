
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
