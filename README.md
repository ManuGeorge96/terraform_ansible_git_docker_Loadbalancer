# terraform_ansible_git_docker_Loadbalancer

## About

This is an ansible playbook, it make use of terraform code to deploy aws infra( EC2, ALB, SGs, VPC) and ansible yml to setup containers on the EC2 instances, which is then load balanced with a Nginx Container.
The Playbook itself contain two plays, one for 

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

NOTE: not Included all the service just an outline below.

[<img align="left" alt="Unix" width="700" src="https://raw.githubusercontent.com/ManuGeorge96/ManuGeorge96/master/Tools/terraform_ansible_git_docker_Loadbalancer.drawio.png" />][ln]

[ln]: https://www.linkedin.com/in/manu-george-03453613a
