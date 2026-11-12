mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
    }
  }

  mock_data "aws_region" {
    defaults = {
      name   = "us-east-2"
      region = "us-east-2"
    }
  }

  mock_data "aws_route53_zone" {
    defaults = {
      primary_name_server = "ns-1536.awsdns-00.co.uk"
    }
  }

  mock_resource "aws_service_discovery_service" {
    defaults = {
      arn = "arn:aws:servicediscovery:us-east-2:123456789012:service/srv-mock1234"
    }
  }

  mock_resource "aws_ecs_task_definition" {
    defaults = {
      arn = "arn:aws:ecs:us-east-2:123456789012:task-definition/aembit_agent_controller:1"
    }
  }
}

mock_provider "http" {
  mock_data "http" {
    defaults = {
      status_code   = 200
      response_body = "-----BEGIN CERTIFICATE-----\nMIIBkTCB+wIJAKHHIG...\n-----END CERTIFICATE-----"
    }
  }
}

variables {
  aembit_tenantid            = "test12"
  aembit_agent_controller_id = "00000000-0000-0000-0000-000000000000"
  ecs_cluster                = "test-ecs-cluster"
  ecs_vpc_id                 = "vpc-00000000000000000"
  ecs_subnets                = ["subnet-00000000000000001", "subnet-00000000000000002"]
  ecs_security_groups        = ["sg-00000000000000001"]
}

run "default_service_discovery_and_readiness" {
  command = apply

  assert {
    condition     = length(aws_service_discovery_private_dns_namespace.agent-controller) == 1
    error_message = "Expected Private DNS Namespace to be created when service_discovery_registry_arn is null."
  }

  assert {
    condition     = length(aws_service_discovery_service.agent-controller) == 1
    error_message = "Expected Service Discovery Service to be created when service_discovery_registry_arn is null."
  }

  assert {
    condition     = length(data.aws_route53_zone.agent-controller) == 1
    error_message = "Expected Route 53 Hosted Zone data source to be read when service_discovery_registry_arn is null."
  }

  assert {
    condition     = length(aws_route53_record.agent-controller-soa) == 1
    error_message = "Expected Route 53 SOA record override to be created when service_discovery_registry_arn is null."
  }

  assert {
    condition     = aws_route53_record.agent-controller-soa[0].allow_overwrite == true
    error_message = "Expected Route 53 SOA record to have allow_overwrite = true."
  }

  assert {
    condition     = aws_route53_record.agent-controller-soa[0].type == "SOA"
    error_message = "Expected Route 53 record type to be SOA."
  }

  assert {
    condition     = aws_route53_record.agent-controller-soa[0].ttl == 900
    error_message = "Expected Route 53 SOA record TTL to be 900."
  }

  assert {
    condition     = contains(aws_route53_record.agent-controller-soa[0].records, "${trimsuffix(data.aws_route53_zone.agent-controller[0].primary_name_server, ".")}. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 10")
    error_message = "Expected Route 53 SOA record to preserve the hosted zone MNAME and lower minimum TTL to 10 seconds."
  }

  assert {
    condition     = aws_ecs_service.agent-controller.wait_for_steady_state == true
    error_message = "Expected aws_ecs_service.agent-controller wait_for_steady_state to default to true."
  }

  assert {
    condition     = jsondecode(aws_ecs_task_definition.agent-controller.container_definitions)[0].healthCheck.interval == 5
    error_message = "Expected Agent Controller container healthCheck interval to be 5 seconds."
  }

  assert {
    condition     = jsondecode(aws_ecs_task_definition.agent-controller.container_definitions)[0].healthCheck.startPeriod == 10
    error_message = "Expected Agent Controller container healthCheck startPeriod to be 10 seconds."
  }

  assert {
    condition     = output.agent_proxy_default_environment["AEMBIT_AGENT_CONTROLLER"] == "https://agent-controller.aembit.local:443"
    error_message = "Expected AEMBIT_AGENT_CONTROLLER environment variable to point to https://agent-controller.aembit.local:443."
  }
}

run "existing_service_discovery_registry" {
  command = apply

  variables {
    service_discovery_registry_arn = "arn:aws:servicediscovery:us-east-2:123456789012:service/srv-existing"
  }

  assert {
    condition     = length(aws_service_discovery_private_dns_namespace.agent-controller) == 0
    error_message = "Expected Private DNS Namespace not to be created when service_discovery_registry_arn is provided."
  }

  assert {
    condition     = length(aws_service_discovery_service.agent-controller) == 0
    error_message = "Expected Service Discovery Service not to be created when service_discovery_registry_arn is provided."
  }

  assert {
    condition     = length(data.aws_route53_zone.agent-controller) == 0
    error_message = "Expected Route 53 Hosted Zone data source not to be read when service_discovery_registry_arn is provided."
  }

  assert {
    condition     = length(aws_route53_record.agent-controller-soa) == 0
    error_message = "Expected Route 53 SOA record not to be created when service_discovery_registry_arn is provided."
  }

  assert {
    condition     = aws_ecs_service.agent-controller.wait_for_steady_state == true
    error_message = "Expected aws_ecs_service.agent-controller wait_for_steady_state to remain true when using an existing registry."
  }
}

run "wait_for_steady_state_override" {
  command = apply

  variables {
    wait_for_steady_state = false
  }

  assert {
    condition     = aws_ecs_service.agent-controller.wait_for_steady_state == false
    error_message = "Expected aws_ecs_service.agent-controller wait_for_steady_state to respect var.wait_for_steady_state = false."
  }
}
