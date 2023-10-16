variable "ecs_task_prefix" {
  type = string
  description = "Prefix to include in front of the Agent Controller ECS Task Definitions to ensure uniqueness."
  default = "aembit_"
}

variable "ecs_service_prefix" {
  type = string
  description = "Prefix to include in front of the Agent Controller Service Name to ensure uniqueness."
  default = "aembit_"
}

variable "ecs_private_dns_domain" {
  type = string
  description = "The Private DNS TLD that will be configured and used in the specified AWS VPC for AgentProxy to AgentController connectivity."
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

variable "aembit_trusted_ca_certs" {
  type = string
  description = "Additional CA Certificates that the Aembit AgentProxy should trust for Server Workload connectivity."
  default = null
}

variable "aembit_stack" {
  type = string
  description = "The Aembit Stack which hosts the specified Tenant"
  default = "useast2.aembit.io"
}

variable "agent_controller_image" {
  type = string
  description = "The container image to use for the AgentController installation"
  default = "aembit/aembit_agent_controller:1.8.524"
}

variable "agent_proxy_image" {
  type = string
  description = "The container image to use for the AgentProxy installation"
  default = "aembit/aembit_agent_proxy:1.9.1221"
}

# ECS CLUSTER Specific Variables
variable "ecs_cluster" {
  type = string
  description = "The AWS ECS Cluster into which the Aembit Agent Controller should be deployed"
}

variable "ecs_vpc_id" {
  type = string
  description = "The AWS VPC which the Aembit Agent Controller will be configured for network connectivity. This must be the same VPC as your Client Workload ECS Tasks."
}

variable "ecs_subnets" {
  type = list(string)
  description = "The subnets which the Aembit Agent Controller and Agent Proxy containers can utilize for connectivity between Proxy and Controller and Aembit Cloud."
}

variable "ecs_security_groups" {
  type = list(string)
  description = "The security group(s) which will be assigned to the AgentController service. This security group must allow inbound HTTP access from the AgentProxy containers running in your Client Workload ECS Tasks."
}

variable "agent_controller_task_role_arn" {
  type = string
  description = "The AWS IAM Task Role to use for the Aembit AgentController Service container. This role is used for AgentController registration with the Aembit Cloud Service."
  default = null
}

variable "agent_controller_execution_role_arn" {
  type = string
  description = "The AWS IAM Task Execution Role used by Amazon ECS and Fargate agents for the Aembit AgentController Service"
  default = null
}

variable "log_group_name" {
  type = string
  description = "Specifies the name of an optional log group to create and send logs to for components created by this module."
  default = "/aembit/edge"
}