# Deployment

For the highly available deployment of the Tweet UI, Tweet API and Sentiment Analysis, I chose AWS Fargate with ECS. Fargate is a serverless compute engine for containers. 

The architecture as in the diagram below:

![AWS Diagram](https://github.com/elifkus/coding-challenge/blob/master/terraform/aws-diagram.png?raw=true)

I created public subnets and private subnets within the default VPC. In the public subnet I put an application load balancer that directs traffic to two target groups. Additionally there is the NAT that directs traffic from the elements in the private subnet to the internet gateway.  

In the private subnets, I put the two target groups mentioned above. One of the target groups contains the Fargate tasks for the Tweet UI, and the other one contains the Fargate tasks for the Tweet API. The application load balancer routes the traffic based on the URL. If the URL starts with "/api", the requests are forwarded to the Tweet API, otherwise the requests are forwarded to the Tweet UI.

There is a second load balancer for the sentiment analysis target group which contains the sentiment analysis Fargate tasks. The Fargate tasks for the Tweet API, send their requests to the sentiment load balancer, which is also an application load balancer. 

All Fargate tasks have outbound internet connection over the NAT located in the public network. 




