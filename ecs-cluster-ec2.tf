resource "aws_iam_instance_profile" "ecs-instance-profile_ec2" {
  name = "${var.service}-instance-profile"
  path = "/"
  role = "${aws_iam_role.ecs-service-ec2.id}"

  provisioner "local-exec" {
    command = "sleep 60"
  }

  count = "${data.aws_partition.current.partition == "aws-cn" ? 1 : 0}"
}

resource "aws_launch_configuration" "launch-configuration_ec2" {
  name                 = "${var.service}-launch-configuration"
  image_id             = "ami-0da0590b87d9022f2"
  instance_type        = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.ecs-instance-profile_ec2.id}"
  key_name             = "${var.key-pair-name}"

  root_block_device {
    volume_type           = "standard"
    volume_size           = 100
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }

  associate_public_ip_address = "false"

  user_data = <<EOF
                                  #!/bin/bash -xe
      echo "ECS_CLUSTER=${local.ecs_cluster_name}" >> /etc/ecs/ecs.config
      start ecs
      EOF

  count = "${data.aws_partition.current.partition == "aws-cn" ? 1 : 0}"
}
