resource "aws_ecs_cluster" "this" {
  count = "${var.use_existant_cluster ? 0 : 1 }"
  name  = "${var.project}-${var.environment}"
  tags  = "${merge(local.default_tags, var.tags)}"
}

data "aws_ecs_cluster" "this" {
  count        = "${var.use_existant_cluster ? 1 : 0 }"
  cluster_name = "${var.ecs_cluster_name == "none" ? "${var.project}-${var.environment}" : var.ecs_cluster_name}"
}

locals {
  ecs_cluster_id   = "${element(concat(aws_ecs_cluster.this.*.id, list(var.ecs_cluster_id)), 0)}"
  ecs_cluster_arn  = "${element(concat(aws_ecs_cluster.this.*.arn, data.aws_ecs_cluster.this.*.arn), 0)}"
  ecs_cluster_name = "${element(concat(aws_ecs_cluster.this.*.name, data.aws_ecs_cluster.this.*.cluster_name), 0)}"
}

resource "aws_ecs_task_definition" "this" {
  family = "${var.service}-${var.environment}"

  requires_compatibilities = ["${var.launch_type == "FARGATE" ? "FARGATE" : "EC2"}"]
  cpu                      = "${var.container_cpu}"
  memory                   = "${var.container_memory}"
  network_mode             = "awsvpc"

  execution_role_arn    = "${aws_iam_role.ecs-task-execution.arn}"
  task_role_arn         = "${var.task_role_arn}"
  container_definitions = "${var.container_definitions}"
  tags                  = "${merge(local.default_tags, var.tags)}"
}

data "aws_security_group" "this" {
  id = "${module.security-group.this_security_group_id}"
}

resource "aws_ecs_service" "this" {
  name                               = "${var.service}-${var.environment}"
  cluster                            = "${local.ecs_cluster_id}"
  task_definition                    = "${aws_ecs_task_definition.this.arn}"
  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "100"

  desired_count                     = "${var.autoscaling_min_capacity}"
  health_check_grace_period_seconds = "${var.health_check_grace_period_seconds}"

  capacity_provider_strategy {
    capacity_provider = "${var.use_fargate_spot ? "FARGATE_SPOT" : "FARGATE" }"
    weight = "1"
  }

  network_configuration {
    subnets         = "${var.subnets}"
    security_groups = "${var.create_security_group ? [data.aws_security_group.this.id] : var.security_groups }"
    assign_public_ip = "${var.assign_public_ip}"
  }

  load_balancer {
    target_group_arn = "${var.alb_target_group_arn}"
    container_name   = "${var.container_name == "" ? var.service-var.environment : var.container_name}"
    container_port   = "${var.container_port}"
  }

  lifecycle {
    ignore_changes = ["desired_count"]
  }
}
