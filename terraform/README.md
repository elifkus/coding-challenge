# Deployment

For the highly available deployment of the Tweet UI, Tweet API and Sentiment Analysis, I chose AWS Fargate with ECS. Fargate is a serverless compute engine for containers. 

The architecture as in the diagram below:

<div style="text-align:center">
<img src="https://github.com/elifkus/coding-challenge/blob/master/terraform/aws-diagram.png?raw=true" alt="AWS Diagram" width="600"/>
</div>

I created public subnets and private subnets within the default VPC. In the public subnet I put an application load balancer that directs traffic to two target groups. Additionally there is the NAT that directs traffic from the elements in the private subnet to the internet gateway.  

In the private subnets, I put the two target groups mentioned above. One of the target groups contains the Fargate tasks for the Tweet UI, and the other one contains the Fargate tasks for the Tweet API. The application load balancer routes the traffic based on the URL. If the URL starts with "/api", the requests are forwarded to the Tweet API, otherwise the requests are forwarded to the Tweet UI.

There is a second load balancer for the sentiment analysis target group which contains the sentiment analysis Fargate tasks. The Fargate tasks for the Tweet API, send their requests to the sentiment load balancer, which is also an application load balancer. 

All Fargate tasks have outbound internet connection over the NAT located in the public network. 


## Deployment - Step by Step

I chose to use Terraform for the deployment. 

For the setup, the following steps have to be taken.

### 1. Create ECR registries for the Docker images

```
cd coding-challenge/terraform/ecr
terraform init
terraform apply
```
Copy the ECR registry URL.

### 2. Build images for Tweet API and Sentiment Analysis, then upload to ECR

Copy the ECR base url into the file build-and-push-api-images.sh

```
cd coding-challenge
./build-and-push-api-images.sh
```

### 3. Create the AWS infrastructure and copy the URL for the Tweet API load balancer.  

```
cd coding-challenge/terraform
terraform init
terraform apply
```
Copy the URL for the Tweet API load balancer. 

### 4. Build the image for the Tweet UI using the URL for the load balancer and upload to ECR.

Copy the URL for the Tweet API load balancer into the file build-and-push-ui-image.sh

```
cd coding-challenge
./build-and-push-ui-image.sh
```

### 5. Test the service at the load balancer URL. 

Type in your browser the Tweet API load balancer url.  





