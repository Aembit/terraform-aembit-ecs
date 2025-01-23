locals {
  agent_proxy_default_environment_variables = [
        {"name": "AEMBIT_AGENT_CONTROLLER", "value": "https://${aws_service_discovery_service.agent-controller.name}.${aws_service_discovery_private_dns_namespace.agent-controller.name}:443"},
        {"name": "TRUSTED_CA_CERTS", "value": local.all_trusted_ca_certs_base64 },
        {"name": "AEMBIT_RESOURCE_SET_ID", "value": var.agent_proxy_resource_set_id },
        {"name": "AEMBIT_AGENT_PROXY_DEPLOYMENT_MODEL", "value": "ecs_fargate" }
  ]
}

# Output for Agent Proxy sidecar container that must be added to Client Workload Task Definition
output "agent_proxy_container" {
    value = jsonencode({
        name = "aembit_agent_proxy"
        image = var.agent_proxy_image
        essential = true
        portMappings = [{
            name          = "aembit_agent_proxy_http"
            containerPort = 8000
            hostPort      = 8000
            protocol      = "tcp"
            appProtocol   = "http"
        }]
        logConfiguration = (var.log_group_name != null ? {
            logDriver = "awslogs"
            options = {
                awslogs-group = aws_cloudwatch_log_group.aembit_edge[0].name
                awslogs-region = data.aws_region.current.name
                awslogs-stream-prefix = "agent-proxy"
            }
        } : null)
        environment = local.agent_proxy_default_environment_variables
    })
}

output "agent_proxy_default_env_variables" {
    value = local.agent_proxy_default_environment_variables
}

output "aembit_http_proxy" {
    value = "http://localhost:8000"
}

output "aembit_https_proxy" {
    value = "http://localhost:8000"
}
