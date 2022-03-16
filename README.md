# terraform_ansible_git_docker_Loadbalancer

## About

This is an ansible playbook, it make use of terraform code to deploy aws infra( EC2, ALB, SGs, VPC) and ansible yml to setup containers on the EC2 instances, which is then load balanced with a Nginx Container.

## Outline

- <b>main.yml</b>
   
  - Invoke Terraform scripts.
  - Set Dynamic Inventory files.
  - Create and configure Docker containers.
  - Pushes latest image to Docker HUB.

- <b>terraform/main.tf</b>
   - Setting UP VPC with mentioned CIDR block
   - Create EC2 instances, on the mentioned AZs.
   - Configure Application Load Balancer.


