data "aws_partition" "current" {
}

locals {
  default_tags = {
    Name        = "${var.project}-${var.environment}"
  }
}

