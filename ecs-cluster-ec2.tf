resource "aws_ecs_cluster" "this" {
  count = "${ var.use_existant_cluster ? 0 : 1 }"
  name  = "${var.project}-${var.environment}"
  tags  = "${merge(local.default_tags, var.tags)}"
}

data "aws_ecs_cluster" "this" {
  count        = "${ var.use_existant_cluster ? 1 : 0 }"
  cluster_name = "${var.ecs_cluster_name}"
}

locals {
  ecs_cluster_id   = "${element(concat(aws_ecs_cluster.this.*.id, list(var.ecs_cluster_id)), 0)}"
  ecs_cluster_arn  = "${element(concat(aws_ecs_cluster.this.*.arn, data.aws_ecs_cluster.this.*.arn), 0)}"
  ecs_cluster_name = "${element(concat(aws_ecs_cluster.this.*.name, data.aws_ecs_cluster.this.*.cluster_name), 0)}"
}

resource "aws_iam_instance_profile" "ecs-instance-profile" {
  name = "ecs-instance-profile"
  path = "/"
  role = "${aws_iam_role.ecs-service.id}"
  provisioner "local-exec" {
    command = "sleep 60"
  }
  count = "${var.ecs_launch_type == "EC2" ? 1 : 0}"
}

resource "aws_launch_configuration" "ecs-launch-configuration" {
  name                        = "ecs-launch-configuration"
  image_id                    = "ami-006004b7d4d7fd134"
  instance_type               = "t2.medium"
  iam_instance_profile        = "${aws_iam_instance_profile.ecs-instance-profile.id}"

  root_block_device {
    volume_type               = "standard"
    volume_size               = 100
    delete_on_termination     = true
  }

  lifecycle {
    create_before_destroy     = true
  }

  associate_public_ip_address = "false"
  key_name                    = "testone"
  user_data                   = "#!/bin/bash\necho ECS_CLUSTER='${var.ecs_cluster_name}' > /etc/ecs/ecs.config"
  count                       = "${var.ecs_launch_type == "EC2" ? 1 : 0}"
}

resource "aws_autoscaling_group" "ecs-autoscaling-group" {
  name                        = "ecs-autoscaling-group"
  max_size                    = "2"
  min_size                    = "1"
  desired_capacity            = "1"

  vpc_zone_identifier         = ["${var.vpc_id}"]
  launch_configuration        = "${aws_launch_configuration.ecs-launch-configuration.name}"
  health_check_type           = "ELB"

  tag {
    key = "Name"
    value = "${var.project}-${var.environment}"
    propagate_at_launch = true
  }
  count                       = "${var.ecs_launch_type == "EC2" ? 1 : 0}"
}

resource "aws_ecs_task_definition" "this" {
  family                      = "${var.service}-${var.environment}"

  requires_compatibilities    = ["EC2"]
#  cpu                        = "${var.container_cpu}"
#  memory                     = "${var.container_memory}"
  network_mode                = "awsvpc"

  execution_role_arn          = "${aws_iam_role.ecs-task-execution.arn}"
  task_role_arn               = "${var.task_role_arn}"
  container_definitions       = "${var.container_definitions}"
  tags                        = "${merge(local.default_tags, var.tags)}"
  count                       = "${var.ecs_launch_type == "EC2" ? 1 : 0}"
}

data "aws_security_group" "this" {
  id = "${module.security-group.this_security_group_id}"
}

resource "aws_ecs_service" "this" {
  name                               = "${var.service}-${var.environment}"
  cluster                            = "${local.ecs_cluster_id}"
  task_definition                    = "${aws_ecs_task_definition.this.arn}"
  launch_type                        = "EC2"
  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "100"

  desired_count                      = "${var.minimum_service_capacity}"
  health_check_grace_period_seconds  = "${var.health_check_grace_period_seconds}"

  network_configuration {
    subnets                          = ["${var.subnets}"]
    security_groups                  = ["${data.aws_security_group.this.id}"]
  }

  load_balancer {
    target_group_arn                 = "${var.alb_target_group_arn}"
    container_name                   = "${var.service}-${var.environment}"
    container_port                   = "${var.container_port}"
  }

  lifecycle {
    ignore_changes                   = ["desired_count"]
  }
  count                              = "${var.ecs_launch_type == "EC2" ? 1 : 0}"
}
