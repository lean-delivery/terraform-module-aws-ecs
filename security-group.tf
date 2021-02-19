module "security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.17.0"

  # insert the 2 required variables here
  name        = "${var.project}-${var.environment}-ecs-fargate-${var.service}"
  description = "${upper(var.project)} ${title(var.environment)} Fargate Container Security Group"
  vpc_id      = var.vpc_id

  ingress_with_self = [{
    "from_port"   = 0
    "to_port"     = 0
    "protocol"    = -1
    "description" = "Allow Self"
  }]

  egress_with_cidr_blocks = [{
    "from_port"   = 0
    "to_port"     = 0
    "protocol"    = -1
    "description" = "Allow all outbound"
  }]
  egress_cidr_blocks = ["0.0.0.0/0"]

  tags = merge(local.default_tags, var.tags)
}

