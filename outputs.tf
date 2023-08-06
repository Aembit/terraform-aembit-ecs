# Output for AgentProxy SideCar container that must be added to Client Workload Task Definition
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
        environment = [
            {"name": "AEMBIT_AGENT_CONTROLLER", "value": "http://${aws_service_discovery_service.agent-controller.name}.${aws_service_discovery_private_dns_namespace.agent-controller.name}:80"},
            {"name": "TRUSTED_CA_CERTS", "value": ""},
            {"name": "RUST_LOG", "value": "debug"},
        ]
    })
}

output "aembit_http_proxy" {
    value = "http://localhost:8000"
}

output "aembit_https_proxy" {
    value = "http://localhost:8000"
}
