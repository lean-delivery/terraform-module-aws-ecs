resource "aws_ecs_cluster" "this" {
  name = "${var.project}-${var.environment}"
  tags = "${merge(local.default_tags, var.tags)}"
}

resource "aws_ecs_task_definition" "this" {
  family = "${var.service}-${var.environment}"

  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.container_cpu}"
  memory                   = "${var.container_memory}"
  network_mode             = "awsvpc"

  execution_role_arn = "${data.aws_iam_role.ecs-task-execution.arn}"

  container_definitions = "${var.container_definitions}"
  tags                  = "${merge(local.default_tags, var.tags)}"
}

data "aws_security_group" "this" {
  id = "${module.security-group.this_security_group_id}"
}

resource "aws_ecs_service" "this" {
  name                               = "${var.service}-${var.environment}"
  cluster                            = "${aws_ecs_cluster.this.id}"
  task_definition                    = "${aws_ecs_task_definition.this.arn}"
  launch_type                        = "FARGATE"
  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "100"

  desired_count                     = "${var.minimum_service_capacity}"
  health_check_grace_period_seconds = "30"

  network_configuration {
    subnets         = ["${var.subnets}"]
    security_groups = ["${data.aws_security_group.this.id}"]
  }

  load_balancer {
    target_group_arn = "${var.alb_target_group_arn}"
    container_name   = "${var.service}-${var.environment}"
    container_port   = "${var.container_port}"
  }
}
