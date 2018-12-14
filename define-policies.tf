data "aws_iam_policy_document" "ecs-service-allow-ec2" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:AttachNetworkInterface",
      "ec2:CreateNetworkInterface",
      "ec2:CreateNetworkInterfacePermission",
      "ec2:DeleteNetworkInterface",
      "ec2:DeleteNetworkInterfacePermission",
      "ec2:Describe*",
      "ec2:DetachNetworkInterface",
    ]

    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "ecs-service-allow-elb" {
  statement {
    effect = "Allow"

    actions = [
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:RegisterTargets",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "ecs-service-allow-ec2" {
  name        = "ecs-service-allow-ec2-${var.project}-${var.service}-${var.environment}"
  description = "ECS Service policy to access EC2"
  policy      = "${data.aws_iam_policy_document.ecs-service-allow-ec2.json}"
}

resource "aws_iam_policy" "ecs-service-allow-elb" {
  name        = "ecs-service-allow-elb-${var.project}-${var.service}-${var.environment}"
  description = "ECS Service policy to access ELB"
  policy      = "${data.aws_iam_policy_document.ecs-service-allow-elb.json}"
}

resource "aws_iam_role" "ecs-service" {
  name = "ecs-service-${var.project}-${var.service}-${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = "${merge(local.default_tags, var.tags)}"
}

resource "aws_iam_role_policy_attachment" "attach-allow-ec2" {
  role       = "${aws_iam_role.ecs-service.name}"
  policy_arn = "${aws_iam_policy.ecs-service-allow-ec2.arn}"
}

resource "aws_iam_role_policy_attachment" "attach-allow-elb" {
  role       = "${aws_iam_role.ecs-service.name}"
  policy_arn = "${aws_iam_policy.ecs-service-allow-elb.arn}"
}

data "aws_iam_role" "ecs-task-execution" {
  name = "ecsTaskExecutionRole"
}
