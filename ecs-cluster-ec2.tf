resource "aws_iam_instance_profile" "ecs-instance-profile_ec2" {
  name = "ecs-instance-profile"
  path = "/"
  role = "${aws_iam_role.ecs-service-ec2.id}"
  provisioner "local-exec" {
    command = "sleep 60"
  }
  count = "${data.aws_partition.current.partition == "aws-cn" ? "${ var.use_existant_cluster ? 0 : 1 }" : 0}"
}

resource "aws_launch_configuration" "ecs-launch-configuration_ec2" {
  name                        = "ecs-launch-configuration"
  image_id                    = "ami-0da0590b87d9022f2"
  instance_type               = "${var.instance_type}"
  iam_instance_profile        = "${aws_iam_instance_profile.ecs-instance-profile_ec2.id}"
  key_name                    = "${var.key-pair-name}"

  root_block_device {
    volume_type               = "standard"
    volume_size               = 100
    delete_on_termination     = true
  }

  lifecycle {
    create_before_destroy     = true
  }

  associate_public_ip_address = "false"
  user_data                   = <<EOF
                                  #!/bin/bash -xe
      echo "ECS_CLUSTER=${local.ecs_cluster_name}" >> /etc/ecs/ecs.config
      start ecs
      EOF
  count = "${data.aws_partition.current.partition == "aws-cn" ? "${ var.use_existant_cluster ? 0 : 1 }" : 0}"
}

resource "aws_ecs_task_definition" "this_ec2" {
  family                      = "${var.service}-${var.environment}"

  requires_compatibilities    = ["EC2"]
#  cpu                        = "${var.container_cpu}"
#  memory                     = "${var.container_memory}"
  network_mode                = "awsvpc"

  execution_role_arn          = "${aws_iam_role.ecs-task-execution.arn}"
  task_role_arn               = "${var.task_role_arn}"
  container_definitions       = "${var.container_definitions}"
  tags                        = "${merge(local.default_tags, var.tags)}"
  count                       = "${data.aws_partition.current.partition == "aws-cn" ? 1 : 0}"
}

data "aws_security_group" "this_ec2" {
  id = "${module.security-group.this_security_group_id}"
}

resource "aws_ecs_service" "this_ec2" {
  name                               = "${var.service}-${var.environment}"
  cluster                            = "${local.ecs_cluster_id}"
  task_definition                    = "${aws_ecs_task_definition.this_ec2.arn}"
  launch_type                        = "EC2"
  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "100"

  desired_count                      = "${var.minimum_service_capacity}"
  health_check_grace_period_seconds  = "${var.health_check_grace_period_seconds}"

  network_configuration {
    subnets                          = ["${var.subnets}"]
    security_groups                  = ["${data.aws_security_group.this_ec2.id}"]
  }

  load_balancer {
    target_group_arn                 = "${var.alb_target_group_arn}"
    container_name                   = "${var.service}-${var.environment}"
    container_port                   = "${var.container_port}"
  }

  lifecycle {
    ignore_changes                   = ["desired_count"]
  }
  count                              = "${data.aws_partition.current.partition == "aws-cn" ? 1 : 0}"
}
