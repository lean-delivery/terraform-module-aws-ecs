data "aws_ami" "ecs_optimized_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_iam_instance_profile" "ecs-instance-profile_ec2" {
  name = "${var.environment}-${var.service}-instance-profile"
  path = "/"
  role = aws_iam_role.ecs-service-ec2[0].id

  provisioner "local-exec" {
    command = "sleep 60"
  }

  count = var.launch_type == "FARGATE" ? 0 : 1
}

resource "aws_launch_configuration" "launch-configuration_ec2" {
  name_prefix          = "${var.environment}-${var.service}-launch-configuration-"
  image_id             = data.aws_ami.ecs_optimized_ami.id
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.ecs-instance-profile_ec2[0].id
  key_name             = var.key-pair-name

  root_block_device {
    volume_type           = var.volume_type
    volume_size           = var.volume_size
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


  count = var.launch_type == "FARGATE" ? 0 : 1
}

