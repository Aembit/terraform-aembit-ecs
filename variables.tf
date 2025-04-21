variable "ecs_task_prefix" {
  type        = string
  description = "Prefix to include in front of the Agent Controller ECS Task Definitions to ensure uniqueness."
  default     = "aembit_"
}

variable "ecs_service_prefix" {
  type        = string
  description = "Prefix to include in front of the Agent Controller Service Name to ensure uniqueness."
  default     = "aembit_"
}

variable "ecs_private_dns_domain" {
  type        = string
  description = "The Private DNS TLD that will be configured and used in the specified AWS VPC for Agent Proxy to Agent Controller connectivity."
  default     = "aembit.local"
}

# Aembit Specific Variables
variable "aembit_tenantid" {
  type        = string
  description = "The Aembit tenant ID with which to associate this installation and Client Workloads."
}

variable "aembit_agent_controller_id" {
  type        = string
  description = "The Agent Controller ID with which to associate this installation."
}

variable "aembit_trusted_ca_certs" {
  type        = string
  description = "Additional CA Certificates that the Agent Proxy should trust for Server Workload connectivity, base64 encoded."
  default     = null
}

variable "aembit_stack" {
  type        = string
  description = "The Aembit Stack which hosts the specified Tenant."
  default     = "useast2.aembit.io"
}

variable "aembit_http_port_disabled" {
  type        = bool
  description = "If true, the Agent Controller will not listen on its HTTP port (only HTTPS)."
  default     = false
}

variable "agent_controller_log_level" {
  type        = string
  description = "Log level for the Agent Controller. Must be one of: fatal, error, warning, information, debug, verbose."
  default     = "warning"
  validation {
    condition     = contains(["fatal", "error", "warning", "information", "debug", "verbose"], var.agent_controller_log_level)
    error_message = "agent_controller_log_level must be one of: fatal, error, warning, information, debug, verbose."
  }
}

variable "agent_controller_image" {
  type        = string
  description = "The container image to use for the Agent Controller installation."
  default     = "aembit/aembit_agent_controller:1.21.1914"
}

variable "agent_proxy_image" {
  type        = string
  description = "The container image to use for the Agent Proxy installation."
  default     = "aembit/aembit_agent_proxy:1.22.2905"
}

variable "agent_proxy_resource_set_id" {
  type        = string
  description = "The resource set ID to use for the Agent Proxy installation."
  default     = null
}

variable "agent_proxy_environment_variables" {
  type        = map(string)
  description = "A map of environment variables to define in the Agent Proxy container."
  default     = {}
}

# ECS CLUSTER Specific Variables
variable "ecs_cluster" {
  type        = string
  description = "The AWS ECS Cluster into which the Agent Controller should be deployed."
}

variable "ecs_vpc_id" {
  type        = string
  description = "The AWS VPC which the Agent Controller will be configured for network connectivity. This must be the same VPC as your Client Workload ECS Tasks."
}

variable "ecs_subnets" {
  type        = list(string)
  description = "The subnets which the Aembit Agent Controller and Agent Proxy containers can utilize for connectivity between Proxy and Controller and Aembit Cloud."
}

variable "ecs_security_groups" {
  type        = list(string)
  description = "The security group(s) which will be assigned to the Agent Controller service. This security group must allow inbound HTTP access from the Agent Proxy containers running in your Client Workload ECS Tasks."
}

variable "agent_controller_task_role_arn" {
  type        = string
  description = "The AWS IAM Task Role to use for the Agent Controller service container. This role is used for Agent Controller registration with the Aembit Cloud service."
  default     = null
}

variable "agent_controller_execution_role_arn" {
  type        = string
  description = "The AWS IAM Task Execution Role used by Amazon ECS and Fargate agents for the Agent Controller service."
  default     = null
}

variable "log_group_name" {
  type        = string
  description = "Specifies the name of an optional log group to create and send logs to for components created by this module."
  default     = "/aembit/edge"
}
