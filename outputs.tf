# Output for AgentProxy SideCar container
#   To be added to Client Workload Task
output "agent_proxy_container" {
    value = jsonencode({
        name = "aembit-agent-proxy"
        image = var.agent_proxy_image
        essential = true
        portMappings = [{
            name          = "aembit-agent-proxy-http"
            containerPort = 8000
            hostPort      = 8000
            protocol      = "tcp"
            appProtocol   = "http"
        },{
            name          = "aembit-agent-proxy-https"
            containerPort = 8443
            hostPort      = 8443
            protocol      = "tcp"
            appProtocol   = "http"
        }]
        logConfiguration = (var.create_cloudwatch_log_group ? {
            logDriver = "awslogs"
            options = {
                awslogs-group = aws_cloudwatch_log_group.aembit_edge[0].name
                awslogs-region = data.aws_region.current.name
                awslogs-stream-prefix = "agent-proxy"
            }
        } : null)
        environment = [
            {"name": "AEMBIT_AGENT_CONTROLLER", "value": "http://aembit-agent-controller:80"},
            {"name": "TRUSTED_CA_CERTS", "value": ""},
        ]
    })
}

output "ecs_cluster" {
    value = var.ecs_cluster
}