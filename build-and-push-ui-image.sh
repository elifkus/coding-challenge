#!/bin/bash -xv
ECR_REPO=<REPO_URL>
TWEETAPI_SERVICE_URL=<TWEETAPI_SERVICE_URL>

aws ecr get-login-password --profile hivemind --region eu-central-1 | docker login --username AWS --password-stdin $ECR_REPO

#build and push tweet ui
cd tweet-ui

docker build --no-cache --build-arg base_url=$TWEETAPI_SERVICE_URL -t hivemind/tweet-ui -f docker/Dockerfile .
docker tag hivemind/tweet-ui:latest $ECR_REPO/hivemind/tweet-ui:latest
docker push $ECR_REPO/hivemind/tweet-ui:latest
