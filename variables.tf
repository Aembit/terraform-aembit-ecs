# Aembit Specific Variables
variable "aembit_tenantid" {
  type = string
  description = "The Aembit TenantID with which to associate this installation and Client workloads"
}

variable "aembit_stack" {
  type = string
  description = "The Aembit Stack which hosts the specified Tenant"
  default = "useast2.aembit.io"
}

variable "aembit_device_code" {
  type = string
  description = "The AgentController DeviceCode to use for registration"
}

variable "agent_controller_image" {
  type = string
  description = "The container image to use for the AgentController installation"
  default = "880961858887.dkr.ecr.us-east-2.amazonaws.com/aembit_agent_controller:1.3.321"
}

variable "agent_proxy_image" {
  type = string
  description = "The container image to use for the AgentProxy installation"
  default = "aembit/aembit_agent_proxy:1.6.1113-rc"   
}

# ECS CLUSTER Specific Variables
variable "ecs_cluster" {
  type = string
  description = "The AWS ECS Cluster into which the Aembit Agent Controller should be deployed"
}

variable "ecs_subnets" {
  type = list(string)
  description = "The subnets which the Aembit Agent Controller and Agent Proxy containers can utilize for connectivity between Proxy and Controller and Aembit Cloud"
}

variable "ecs_security_groups" {
  type = list(string)
  description = "The security group which will be assigned to the AgentController service"
}

variable "create_cloudwatch_log_group" {
  type = bool
  description = "Determines whether a log group is created by this module for the Aembit Edge containers"
  default = true
}