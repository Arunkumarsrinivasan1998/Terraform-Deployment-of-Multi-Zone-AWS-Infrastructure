# Terraform-Deployment-of-Multi-Zone-AWS-Infrastructure

Deployed AWS infrastructure using Terraform: VPC with 2 subnets in different zones, EC2 instances with security groups, and an application load balancer for automatic load balancing.

Created a VPC with two subnets in different availability zones (us-east-1a and us-east-1b).

Established an internet gateway for the VPC to enable internet access.

Configured route tables to direct traffic to the internet gateway for both subnets.

Set up security groups allowing inbound HTTP and SSH traffic and all outbound traffic.

Provisioned two EC2 instances running web servers in each subnet.

Deployed an application load balancer (ALB) to balance traffic between the instances across availability zones.

Created a target group for the ALB with health checks configured.

Attached both EC2 instances to the target group for load balancing.

Configured an ALB listener to forward traffic to the target group.

Outputted the DNS name of the ALB for accessing the deployed applications.

