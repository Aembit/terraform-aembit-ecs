# Aembit Edge Terraform Module for AWS ECS

## Prerequisites
* Terraform CLI
* AWS CLI
* Client Workload deployed to AWS ECS Fargate

## Quick Start
Generally, you can add the Aembit Edge components to your ECS Cluster and Client Workloads with only 3 steps.
Individualized permissions, security groups, IAM Roles, etc are not within the scope of this document.

**Steps:**
1) Add the Aembit Edge ECS Module to your Terraform code, using configuration such as
    ```hcl
    module "aembit-ecs" {
      source  = "Aembit/ecs/aembit"
      version = "1.x.y" # Find the latest version at https://registry.terraform.io/modules/Aembit/ecs/aembit/latest

      aembit_tenantid = "abc123"
      aembit_agent_controller_id = "00000000-0000-0000-0000-000000000000"

      ecs_cluster = "ecs-cluster"
      ecs_vpc_id = "vpc-00000000000000000"
      ecs_subnets = ["subnet-00000000000000001","subnet-00000000000000002","subnet-00000000000000002"]
      ecs_security_groups = ["sg-000000000000000000"]
    }
    ```
    Note: Additional configuration options are available and described below.

2) Add the Aembit Agent Proxy container definition to your Client Workload Task Definitions. The code below, shows an example of this by injecting ```jsondecode(module.aembit-ecs.agent_proxy_container)``` as the first container of the Task definition for your Client Workload.
    ```hcl
    resource "aws_ecs_task_definition" "workload_task" {
      family                = "workload_task"
      container_definitions = jsonencode([
        jsondecode(module.aembit-ecs.agent_proxy_container),
        {
          name = "workload"
          ...
    ```

3) Add the required environment variables to your Client Workload Task Definitions. For example:
    ```hcl
    environment = [
      {"name": "http_proxy", "value": module.aembit-ecs.aembit_http_proxy},
      {"name": "https_proxy", "value": module.aembit-ecs.aembit_https_proxy}
    ]
    ```

With your Terraform code updated as described, you can then run ```terraform apply``` or your typical Terraform configuration scripts to deploy Aembit Edge into your AWS ECS Client Workloads.

## Configuration
The following tables lists the configurable variables of the module and their default values. All variables are required unless marked optional.
| Parameter | Description | Default |
|-----------|-------------|---------|
| aembit_tenantid | The Aembit TenantID with which to associate this installation and Client workloads. | None |
| aembit_agent_controller_id | The Aembit Agent Controller ID with which to associate this installation. | None |
| aembit_trusted_ca_certs | Additional CA Certificates that the Aembit AgentProxy should trust for Server Workload connectivity. | *Optional* |
| ecs_cluster | The AWS ECS Cluster into which the Aembit Agent Controller should be deployed. | None |
| ecs_vpc_id | The AWS VPC which the Aembit Agent Controller will be configured for network connectivity. This must be the same VPC as your Client Workload ECS Tasks. | None |
| ecs_subnets | The subnets which the Aembit Agent Controller and Agent Proxy containers can utilize for connectivity between Proxy and Controller and Aembit Cloud. | None |
| ecs_security_groups | The security group which will be assigned to the AgentController service. This security group must allow inbound HTTP access from the AgentProxy containers running in your Client Workload ECS Tasks. | None |
| agent_controller_task_role_arn | The AWS IAM Task Role to use for the Aembit AgentController Service container. This role is used for AgentController registration with the Aembit Cloud Service. | ```arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsTaskExecutionRole``` |
| agent_controller_execution_role_arn | The AWS IAM Task Execution Role used by Amazon ECS and Fargate agents for the Aembit AgentController Service. | ```arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsTaskExecutionRole``` |
| log_group_name | Specifies the name of an optional log group to create and send logs to for components created by this module. | ```/aembit/edge``` *Optional, can be set to ```null```* |
| agent_controller_image | The container image to use for the AgentController installation. |  |
| agent_proxy_image | The container image to use for the AgentProxy installation. | |
| aembit_stack | The Aembit Stack which hosts the specified Tenant. | ```useast2.aembit.io``` |
| ecs_task_prefix | Prefix to include in front of the Agent Controller ECS Task Definitions to ensure uniqueness. | ```aembit_``` |
| ecs_service_prefix | Prefix to include in front of the Agent Controller Service Name to ensure uniqueness. | ```aembit_``` |
| ecs_private_dns_domain | The Private DNS TLD that will be configured and used in the specified AWS VPC for AgentProxy to AgentController connectivity. | ```aembit.local``` |


## AWS Resources
The following AWS Resources are created and managed as part of this Terraform Module.
* **AWS ECS Service (Service and Task Definition)**
  This AWS ECS Fargate Service will run the Aembit AgentController container and ensure that all Aembit Edge managed Client Workloads are enrolled appropriately.
* **AWS ECS Service Discovery (DNS Record & Namespace)**
  This Route53 Private Hosted Zone will be created by AWS Cloud Map and provide DNS resolution of the Aembit AgentController so that the Aembit AgentProxy can connect appropriately.
* **AWS CloudWatch Log Group**
  This optional CloudWatch Group will be created and configured to store all logs from the Aembit AgentProxy and AgentController containers.