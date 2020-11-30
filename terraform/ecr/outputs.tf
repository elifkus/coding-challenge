output "sentiment-analysis-repo" {
  value = aws_ecr_repository.sentiment-analysis-repo.repository_url
}
output "tweet-api-repo" {
  value = aws_ecr_repository.tweet-api-repo.repository_url
}
output "tweet-ui-repo" {
  value = aws_ecr_repository.tweet-ui-repo.repository_url
}
