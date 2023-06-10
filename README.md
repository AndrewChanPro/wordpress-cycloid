# Wordpress-cycloid

This is infrastructure as code to deploy wordpress in an AWS ECS cluster.

# Requirements

- AWS default credentials are setup in environment variables or in ~/.aws/config
- Packer, Docker, Terraform are installed

# How do deploy

Run the following:

`./deploy.sh`

# Technical Test Questions

## How did you approach the test?

1. I was not familiar with wordpress and Ansible. For wordpress, I spin a multi-container application with mysql database and wordpress with docker-compose. I pulled the wordpress image from dockerhub. This allowed me to understand what configs were needed to make the application work. As for ansible, I found a guide on building Docker images with packer and ansible: https://alex.dzyoba.com/blog/packer-for-docker/. While referencing Packer and Ansible docs such as https://developer.hashicorp.com/packer/plugins/provisioners/ansible/ansible, I was able to adjust my configs to my needs. To test my image was properly built when running packer, I locally ran the wordpress container to ensure there was some kind of response. I make sure that the ECR repo is provisioned before I push my image there.

As for the infrastructure, I was already familiar with the all the components needed to make it work. I started with the networking configuration and work my way to the ECS cluster, service and task definition. I make sure that I seperate them in multiple files. For the purpose of this test, I keep all configuration in one single module.

## How did you run your project?

You can run this by running: 

`./deploy.sh`

## What components interact with each other?

There are two main components to this application.

1. The wordpress container runs both the frontend and backend.
2. The RDS database which stores information about the wordpress website.

The wordpress container has access to the db endpoint with the username and password; it reads and writes to the db.

## What problems did you encounter?

1. I misconfigured the ansible playbook. When I was trying to build a image from debian, I found that none of dependencies that I defined existed in the container. It turns out that I was actually not installing in the container. I was installing all the dependencies in the host. I found this out by printing the current user and os as a command in an ansible task.
2. I kept getting 500 error when trying accessing my ecs cluster. In order to determine if there was a network issue, I temporarily allowed ICMP requests to check if I could ping one of the ecs tasks. I was able to ping it so I looked somewhere else. I later found out that my environment variables were configured incorrectly which is why the containers did not have access to the db. Unfortunately, despite setting up logs, I did not any logs hinting this. It is possible that I need to configure the container logs more appropriately.

## How would you have done things to achieve the best HA/automated architecture?

- Enable multi-az for RDS.
- Setup automatic backups for RDS.
- Use multiple subnets and az for ecs service ( done )
- Add better observability to our ecs cluster with Datadog or another tool

## Please share any ideas you have to improve this kind of infrastructure

- Store secrets in Secrets Manager and store secrets arn in environment variables instead
- Add health check in ALB
- Put terraform state in S3 and use Dynodb for state locking
- Push semantic versioning tag to the Docker image and tag all the infrastructure with the same tag

## Tomorrow we want to put this project in production. What would be your advice and choices to achieve that? In other words, the infrastructure and external services like monitoring, etc

- I would add better monitoring for this service for example datadog. We can use setup up dashboard and alerts with the metrics we have available. We would need to setup the appropriate SLIs, SLOs and work with the stakeholder to define the SLAs. An example of an SLO could be for example: The wordpress site will be available 99.9% in the past month. Availability is measured by the ability to reach the main page with a status of 200. Downtime starts when we recieve a non 200 status.
- Add cloudfront in front of ecs cluster for regional edge caching. Stup SSL certificate in the cloudfront distribution.
- Register root domain and create ANAME record to Cloudfront distribution.
- Setup SSL termination at ALB.