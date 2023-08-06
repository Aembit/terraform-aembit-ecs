variable "ecs_task_prefix" {
  type = string
  description = "Prefix to include in front of the ECS Task Definitions to ensure uniqueness"
  default = "aembit_"
}

variable "ecs_service_prefix" {
  type = string
  description = "Prefix to include in front of the ECS Service Name to ensure uniqueness"
  default = "aembit_"
}

variable "ecs_private_dns_domain" {
  type = string
  description = "The Private DNS TLD that will be configured and used in the specified AWS VPC for AgentProxy to AgentController connectivity"
  default = "aembit.local"
}

# Aembit Specific Variables
variable "aembit_tenantid" {
  type = string
  description = "The Aembit TenantID with which to associate this installation and Client workloads"
}

variable "aembit_agent_controller_id" {
  type = string
  description = "The Aembit Agent Controller ID with which to associate this installation" 
}

variable "aembit_stack" {
  type = string
  description = "The Aembit Stack which hosts the specified Tenant"
  default = "useast2.aembit.io"
}

variable "agent_controller_image" {
  type = string
  description = "The container image to use for the AgentController installation"
  default = "aembit/aembit_agent_controller:1.7.426-rc"
}

variable "agent_proxy_image" {
  type = string
  description = "The container image to use for the AgentProxy installation"
  default = "880961858887.dkr.ecr.us-east-2.amazonaws.com/aembit_agent_proxy:1.7.1141"
}

# ECS CLUSTER Specific Variables
variable "ecs_cluster" {
  type = string
  description = "The AWS ECS Cluster into which the Aembit Agent Controller should be deployed"
}

variable "ecs_vpc_id" {
  type = string
  description = "value"
}

variable "ecs_subnets" {
  type = list(string)
  description = "The subnets which the Aembit Agent Controller and Agent Proxy containers can utilize for connectivity between Proxy and Controller and Aembit Cloud"
}

variable "ecs_security_groups" {
  type = list(string)
  description = "The security group which will be assigned to the AgentController service"
}

variable "agent_controller_task_role_arn" {
  type = string
  description = "The AWS IAM Task Role to use for the Aembit AgentController Service container"
  default = null
}

variable "agent_controller_execution_role_arn" {
  type = string
  description = "The AWS IAM Task Execution Role used by Amazon ECS and Fargate agents for the Aembit AgentController Service"
  default = null
}

variable "log_group_name" {
  type = string
  description = "Determines whether a log group is created by this module for the Aembit Edge containers"
  default = "/aembit/edge"
}