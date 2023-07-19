# AWS Current Caller to get AWS Account ID and Region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

##########################################################################################
# AgentController Task & Service
resource "aws_ecs_task_definition" "agent-controller" {
  family                = "aembit-agent-controller"
  container_definitions = jsonencode([{
    name = "aembit-agent-controller"
    image = var.agent_controller_image
    essential = true
    portMappings = [{
      name          = "aembit-agent-controller-http"
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
      appProtocol   = "http"
    }]
    logConfiguration = (var.create_cloudwatch_log_group ? {
      logDriver = "awslogs"
      options = {
        awslogs-group = aws_cloudwatch_log_group.aembit_edge[0].name
        awslogs-region = data.aws_region.current.name
        awslogs-stream-prefix = "agent-controller"
      }
    } : null)
    environment = [
      {"name": "TenantId", "value": var.aembit_tenantid },
      {"name": "DEBUG", "value": "1" },
      {"name": "StackDomain", "value": var.aembit_stack },
      {"name": "DeviceCode", "value": var.aembit_device_code }
    ]
  }])
  execution_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsTaskExecutionRole"
  cpu = 256
  memory = 512
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_ecs_service" "agent-controller" {
  name = "aembit-agent-controller"
  desired_count = 1
  launch_type = "FARGATE"
  cluster = var.ecs_cluster
  task_definition = aws_ecs_task_definition.agent-controller.arn
  enable_execute_command = false
  
  service_connect_configuration {
    enabled = true
    service {
      discovery_name = "aembit-agent-controller"
      port_name = "aembit-agent-controller-http"
      client_alias {
        dns_name = "aembit-agent-controller"
        port = 80
      }
    }
  }
  
  network_configuration {
    assign_public_ip = true   # Required to download Container Images, can be improved
    subnets = var.ecs_subnets
    security_groups = var.ecs_security_groups
  }          
}
##########################################################################################

# Log Group Resource (Optional)
resource "aws_cloudwatch_log_group" "aembit_edge" {
  count = (var.create_cloudwatch_log_group ? 1 : 0)

  name                = "/aembit/edge"
  retention_in_days   = 30
}