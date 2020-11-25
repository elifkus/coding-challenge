#!/bin/bash -xv
ECR_REPO=401172141612.dkr.ecr.eu-central-1.amazonaws.com

aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin $ECR_REPO

#build and push sentiment analysis
cd sentiment-analysis
docker build -t sentiment-analysis -f docker/Dockerfile .
docker tag sentiment-analysis:latest $ECR_REPO/sentiment-analysis:latest
docker push $ECR_REPO/sentiment-analysis:latest
