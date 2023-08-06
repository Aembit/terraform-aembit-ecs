# Aembit Edge Terraform Module for AWS ECS

## Prerequisites
* Terraform CLI
* AWS CLI
* Client Workload deployed to AWS ECS Fargate

## Configuration & Deployment
Generally, you can add the Aembit Edge components to your ECS Cluster and Client Workloads with only 3 steps.
Individualized permissions, security groups, IAM Roles, etc are not within the scope of this document.

Steps:
1) Add the Aembit Edge ECS Module to your Terraform code, using configuration such as
    ```
    module "aembit-ecs" {
      source = "../../../terraform-aembit-ecs"

      aembit_tenantid = "abc123"
      aembit_agent_controller_id = "00000000-0000-0000-0000-000000000000"

      ecs_cluster = "ecs-cluster"
      ecs_vpc_id = "vpc-00000000000000000"
      ecs_subnets = ["subnet-00000000000000001","subnet-00000000000000002","subnet-00000000000000002"]
      ecs_security_groups = ["sg-000000000000000000"]
    }
    ```
    Note: Additional configuration options are available and described below.

2) Add the Aembit Agent Proxy container definition to your Client Workload Task Definitions. An example is available below, the key element being the configuration: ```jsondecode(module.aembit-ecs.agent_proxy_container),```
    ```
    resource "aws_ecs_task_definition" "workload_task" {
      family                = "workload_task"
      container_definitions = jsonencode([
        jsondecode(module.aembit-ecs.agent_proxy_container),
        {
          name = "workload"
    ```

3) Add the require environment variables to your Client Workload Task Definitions. For example:
    ```
    environment = [
      {"name": "http_proxy", "value": module.aembit-ecs.aembit_http_proxy},
      {"name": "https_proxy", "value": module.aembit-ecs.aembit_https_proxy}
    ]
    ```

4) Run ```terraform apply``` or your typical terraform configuration scripts.


## Configuration Variables
When you have completed using the ECS Globex deployment, you can simply run ```./deploy-tf.sh --destroy``` to tear everything down.
