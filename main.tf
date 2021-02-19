data "aws_partition" "current" {
}

locals {
  default_tags = {
    Name        = "${var.project}-${var.environment}"
    Project     = var.project
    Environment = var.environment
  }
}

