# AWS Current Caller to get AWS Account ID and Region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_service_discovery_service" "agent-controller" {
  name        = "agent-controller"
  description = "Private DNS Record for Aembit AgentController connectivity"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.agent-controller.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_private_dns_namespace" "agent-controller" {
  name        = var.ecs_private_dns_domain
  description = "Private DNS Namespace for Aembit AgentController connectivity"
  vpc         = var.ecs_vpc_id
}

##########################################################################################
# AgentController Task & Service
resource "aws_ecs_task_definition" "agent-controller" {
  family = "${var.ecs_task_prefix}agent_controller"
  container_definitions = jsonencode([{
    name      = "${var.ecs_task_prefix}agent_controller"
    image     = var.agent_controller_image
    essential = true
    portMappings = [{
      name          = "aembit_agent_controller_https"
      containerPort = 443
      hostPort      = 443
      protocol      = "tcp"
    }]
    logConfiguration = (var.log_group_name != null ? {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.aembit_edge[0].name
        awslogs-region        = data.aws_region.current.name
        awslogs-stream-prefix = "agent_controller"
      }
    } : null)
    environment = concat(
    [
      { name = "AEMBIT_TENANT_ID", value = var.aembit_tenantid },
      { name = "AEMBIT_STACK_DOMAIN", value = var.aembit_stack },
      { name = "AEMBIT_AGENT_CONTROLLER_ID", value = var.aembit_agent_controller_id },
      { name = "AEMBIT_MANAGED_TLS_HOSTNAME", value = "${aws_service_discovery_service.agent-controller.name}.${aws_service_discovery_private_dns_namespace.agent-controller.name}" },
      { name = "AEMBIT_HTTP_PORT_DISABLED", value = tostring(var.aembit_http_port_disabled) }
    ],
    [
      for name, value in var.agent_controller_environment_variables : {
        name  = name
        value = value
      }
    ])
    healthCheck = {
      retries     = 6
      command     = ["CMD-SHELL", "/app/healthCheck"]
      timeout     = 3
      interval    = 7
      startPeriod = 30
    }
  }])
  task_role_arn            = (var.agent_controller_task_role_arn == null ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsTaskExecutionRole" : var.agent_controller_task_role_arn)
  execution_role_arn       = (var.agent_controller_execution_role_arn == null ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsTaskExecutionRole" : var.agent_controller_execution_role_arn)
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

locals {
  # Extract the "base domain" (e.g. aembit-eng.com ) from the stack domain.
  _domain_parts = split(".", "${var.aembit_stack}")
  base_domain   = join(".", slice("${local._domain_parts}", 1, 3))

  # Concatenating passed-in trusted CA certs with the tenant root CA
  _passed_in_certs_pem        = !(var.aembit_trusted_ca_certs == null || var.aembit_trusted_ca_certs == "") ? base64decode("${var.aembit_trusted_ca_certs}") : null
  _all_trusted_ca_certs_pem   = local._passed_in_certs_pem != null ? "${local._passed_in_certs_pem}\n${data.http.trusted_ca_cert.response_body}" : "${data.http.trusted_ca_cert.response_body}"
  all_trusted_ca_certs_base64 = base64encode("${local._all_trusted_ca_certs_pem}")
}

data "http" "trusted_ca_cert" {
  url = "https://${var.aembit_tenantid}.${local.base_domain}/api/v1/root-ca"

  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "${self.url} returned an unhealthy status code"
    }
  }
}


resource "aws_ecs_service" "agent-controller" {
  name                   = "${var.ecs_service_prefix}agent_controller"
  desired_count          = 1
  launch_type            = "FARGATE"
  cluster                = var.ecs_cluster
  task_definition        = aws_ecs_task_definition.agent-controller.arn
  enable_execute_command = false

  service_registries {
    registry_arn = aws_service_discovery_service.agent-controller.arn
  }

  network_configuration {
    assign_public_ip = true # Required to download Container Images, can be improved
    subnets          = var.ecs_subnets
    security_groups  = var.ecs_security_groups
  }
}
##########################################################################################

# Log Group Resource (Optional)
resource "aws_cloudwatch_log_group" "aembit_edge" {
  count = (var.log_group_name != null ? 1 : 0)

  name              = var.log_group_name
  retention_in_days = 30
}
