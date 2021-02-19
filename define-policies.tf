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
  policy      = data.aws_iam_policy_document.ecs-service-allow-ec2.json
}

resource "aws_iam_policy" "ecs-service-allow-elb" {
  name        = "ecs-service-allow-elb-${var.project}-${var.service}-${var.environment}"
  description = "ECS Service policy to access ELB"
  policy      = data.aws_iam_policy_document.ecs-service-allow-elb.json
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


  count = var.launch_type == "FARGATE" ? 1 : 0
  tags  = merge(local.default_tags, var.tags)
}

resource "aws_iam_role" "ecs-service-ec2" {
  name = "ecs-service-ec2-${var.project}-${var.service}-${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com${data.aws_partition.current.partition == "aws-cn" ? ".cn" : ""}"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF


  count = var.launch_type == "FARGATE" ? 0 : 1
  tags  = merge(local.default_tags, var.tags)
}

resource "aws_iam_role_policy_attachment" "this_ec2" {
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  role       = aws_iam_role.ecs-service-ec2[0].name
  count      = var.launch_type == "FARGATE" ? 0 : 1
}

resource "aws_iam_role_policy_attachment" "this_default_ecs_ec2" {
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
  role       = aws_iam_role.ecs-service-ec2[0].name
  count      = var.launch_type == "FARGATE" ? 0 : 1
}

resource "aws_iam_role_policy_attachment" "attach-allow-ec2_ec2" {
  role       = aws_iam_role.ecs-service-ec2[0].name
  policy_arn = aws_iam_policy.ecs-service-allow-ec2.arn
  count      = var.launch_type == "FARGATE" ? 0 : 1
}

resource "aws_iam_role_policy_attachment" "attach-allow-elb_ec2" {
  role       = aws_iam_role.ecs-service-ec2[0].name
  policy_arn = aws_iam_policy.ecs-service-allow-elb.arn
  count      = var.launch_type == "FARGATE" ? 0 : 1
}

resource "aws_iam_role_policy_attachment" "attach-allow-ec2" {
  role       = aws_iam_role.ecs-service[0].name
  policy_arn = aws_iam_policy.ecs-service-allow-ec2.arn
  count      = var.launch_type == "FARGATE" ? 1 : 0
}

resource "aws_iam_role_policy_attachment" "attach-allow-elb" {
  role       = aws_iam_role.ecs-service[0].name
  policy_arn = aws_iam_policy.ecs-service-allow-elb.arn
  count      = var.launch_type == "FARGATE" ? 1 : 0
}

# data "aws_iam_role" "ecs-task-execution" {
#   name = "ecsTaskExecutionRole"
# }

data "aws_iam_policy_document" "ecs-task-access-ecr" {
  statement {
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]

    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "ecs-task-access-cloudwatch" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "ecs-task-access-ecr" {
  name        = "ecs-task-allow-ec2-${var.project}-${var.service}-${var.environment}"
  description = "ECS task policy to access ECR"
  policy      = data.aws_iam_policy_document.ecs-task-access-ecr.json
}

resource "aws_iam_policy" "ecs-task-access-cloudwatch" {
  name        = "ecs-task-allow-elb-${var.project}-${var.service}-${var.environment}"
  description = "ECS task policy to access CloudWatch"
  policy      = data.aws_iam_policy_document.ecs-task-access-cloudwatch.json
}

resource "aws_iam_role" "ecs-task-execution" {
  name = "ecs-task-${var.project}-${var.service}-${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF


  tags = merge(local.default_tags, var.tags)
}

resource "aws_iam_role_policy_attachment" "attach-allow-ecr" {
  role       = aws_iam_role.ecs-task-execution.name
  policy_arn = aws_iam_policy.ecs-task-access-ecr.arn
}

resource "aws_iam_role_policy_attachment" "attach-allow-cw" {
  role       = aws_iam_role.ecs-task-execution.name
  policy_arn = aws_iam_policy.ecs-task-access-cloudwatch.arn
}

