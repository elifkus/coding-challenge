#!/bin/bash -xv
ECR_REPO=401172141612.dkr.ecr.eu-central-1.amazonaws.com
TWEETAPI_SERVICE_URL=http://tweet-api-278176414.eu-central-1.elb.amazonaws.com

aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin $ECR_REPO

#build and push tweet ui
cd tweet-ui

docker build --no-cache --build-arg base_url=$TWEETAPI_SERVICE_URL -t hivemind/tweet-ui -f docker/Dockerfile .
docker tag hivemind/tweet-ui:latest $ECR_REPO/hivemind/tweet-ui:latest
docker push $ECR_REPO/hivemind/tweet-ui:latest
