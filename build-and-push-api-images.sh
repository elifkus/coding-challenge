#!/bin/bash -xv
ECR_REPO=<ECR_REPO>

aws ecr get-login-password --profile hivemind --region eu-central-1 | docker login --username AWS --password-stdin $ECR_REPO

#build and push sentiment analysis
cd sentiment-analysis
docker build -t hivemind/sentiment-analysis -f docker/Dockerfile .
docker tag hivemind/sentiment-analysis:latest $ECR_REPO/hivemind/sentiment-analysis:latest
docker push $ECR_REPO/hivemind/sentiment-analysis:latest

#build and push tweet api
cd tweet-api
docker build --no-cache -t hivemind/tweet-api -f docker/Dockerfile .
docker tag hivemind/tweet-api:latest $ECR_REPO/hivemind/tweet-api:latest
docker push $ECR_REPO/hivemind/tweet-api:latest