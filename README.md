# Hivemind's Coding Challenge

Welcome.

Hivemind's coding challenge consists in connecting two web services and deploying them in a highly available environment.

## Background

The team is tasked with the development of a simple web UI for sentiment analysis of tweets. The user shall be able to enter a tweet and the UI will return a thumbs up or down depending on the result of the analysis.

Your team has already defined an architecture consisting of a single-page frontend app (dubbed `tweet-ui`), a backend HTTP API (`tweet-api`) and a sentiment analysis service (`sentiment-analysis`). Since the sentiment analysis service shouldn't be accessible publicly, the frontend should request analyses via the backend HTTP API.

## Tasks

You are tasked with the development of the `tweet-api` service that will be consumed by the frontend. It will serve as the intermediary between the frontend and the sentiment analysis service.

The team leaves it up to you to choose the programming language for this task, but they are big functional programming geeks and frown upon anything else.

Upon completion, deploy the entire system on AWS using Terraform or CDK.

Fork this project to get started, there is no time limit.

Happy Hacking!

## Services

* [tweet UI](./tweet-ui/README.md)
* [tweet API](./tweet-api/README.md)
* [sentiment analysis](./sentiment-analysis/README.md)

## Resources

* [AWS Cloud Development Kit](https://aws.amazon.com/cdk/)
* [Terraform](https://www.terraform.io/)
