data "aws_iam_policy_document" "service-autoscaling" {
  statement {
    effect = "Allow"

    actions = [
      "application-autoscaling:*",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:GetMetricStatistics",
      "ecs:DescribeServices",
      "ecs:UpdateService",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "service-autoscaling" {
  name        = "service-autoscaling-${var.project}-${var.service}-${var.environment}"
  description = "ECS autoscaling policy"
  policy      = "${data.aws_iam_policy_document.service-autoscaling.json}"
}

resource "aws_iam_role" "service-autoscaling" {
  name = "ecs-autoscaling-${var.project}-${var.service}-${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "application-autoscaling.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = "${merge(local.default_tags, var.tags)}"
}

resource "aws_iam_role_policy_attachment" "attach-autoscaling" {
  role       = "${aws_iam_role.service-autoscaling.name}"
  policy_arn = "${aws_iam_policy.service-autoscaling.arn}"
}

resource "aws_cloudwatch_metric_alarm" "cpu-high" {
  alarm_name          = "${title(lower(var.project))}-${title(lower(var.environment))}-${title(lower(var.service))}-AutoScalingCPUAlarmHigh"
  alarm_description   = "Containers CPU Utilization High"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  namespace           = "AWS/EC2"
  period              = "60"
  threshold           = "50"

  dimensions {
    ClusterName = "${aws_ecs_cluster.this.id}"
    ServiceName = "${var.service}-${var.environment}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.scale_policy_high.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "cpu-low" {
  alarm_name          = "${title(lower(var.project))}-${title(lower(var.environment))}-${title(lower(var.service))}-AutoScalingCPUAlarmLow"
  alarm_description   = "Containers CPU Utilization Low"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/EC2"
  period              = "60"
  threshold           = "40"

  dimensions {
    ClusterName = "${aws_ecs_cluster.this.id}"
    ServiceName = "${var.service}-${var.environment}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.scale_policy_low.arn}"]
}

resource "aws_appautoscaling_policy" "scale_policy_high" {
  name               = "${title(lower(var.project))}-${title(lower(var.environment))}-${title(lower(var.service))}-ScalePolicyHigh"
  policy_type        = "StepScaling"
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = ["aws_appautoscaling_target.ecs_target"]
}

resource "aws_appautoscaling_policy" "scale_policy_low" {
  name               = "${title(lower(var.project))}-${title(lower(var.environment))}-${title(lower(var.service))}-ScalePolicyLow"
  policy_type        = "StepScaling"
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = ["aws_appautoscaling_target.ecs_target"]
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this.name}"
  role_arn           = "${aws_iam_role.service-autoscaling.arn}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}
