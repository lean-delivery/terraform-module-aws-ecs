resource "aws_cloudwatch_metric_alarm" "cpu-high" {
  alarm_name          = "${title(lower(var.project))}-${title(lower(var.environment))}-${title(lower(var.service))}-AutoScalingCPUAlarmHigh"
  alarm_description   = "Containers CPU Utilization High"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  namespace           = "AWS/ECS"
  period              = "60"
  threshold           = var.autoscaling_cpu_high_threshold

  dimensions = {
    ClusterName = local.ecs_cluster_name
    ServiceName = "${var.service}-${var.environment}"
  }

  alarm_actions = [aws_appautoscaling_policy.scale_policy_high.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu-low" {
  alarm_name          = "${title(lower(var.project))}-${title(lower(var.environment))}-${title(lower(var.service))}-AutoScalingCPUAlarmLow"
  alarm_description   = "Containers CPU Utilization Low"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/ECS"
  period              = "60"
  threshold           = var.autoscaling_cpu_low_threshold

  dimensions = {
    ClusterName = local.ecs_cluster_name
    ServiceName = "${var.service}-${var.environment}"
  }

  alarm_actions = [aws_appautoscaling_policy.scale_policy_low.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu-high_ec2" {
  alarm_name          = "${title(lower(var.project))}-${title(lower(var.environment))}-${title(lower(var.service))}-AutoScalingCPUUtilizationHigh_ec2"
  alarm_description   = "Node CPU Utilization High"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  namespace           = "AWS/EC2"
  period              = "60"
  threshold           = var.autoscaling_cpu_high_threshold

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscaling-group[0].name
  }

  count         = var.launch_type == "FARGATE" ? 0 : 1
  alarm_actions = [aws_autoscaling_policy.scale_policy_high_ec2[0].arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu-low_ec2" {
  alarm_name          = "${title(lower(var.project))}-${title(lower(var.environment))}-${title(lower(var.service))}-AutoScalingCPUUtilizationLow_ec2"
  alarm_description   = "Node CPU Utilization Low"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  namespace           = "AWS/EC2"
  period              = "60"
  threshold           = var.autoscaling_cpu_low_threshold

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscaling-group[0].name
  }

  count         = var.launch_type == "FARGATE" ? 0 : 1
  alarm_actions = [aws_autoscaling_policy.scale_policy_low_ec2[0].arn]
}

resource "aws_appautoscaling_policy" "scale_policy_high" {
  name               = "${title(lower(var.project))}-${title(lower(var.environment))}-${title(lower(var.service))}-ScalePolicyHigh"
  policy_type        = "StepScaling"
  resource_id        = "service/${local.ecs_cluster_name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [aws_appautoscaling_target.ecs_target]
}

resource "aws_appautoscaling_policy" "scale_policy_low" {
  name               = "${title(lower(var.project))}-${title(lower(var.environment))}-${title(lower(var.service))}-ScalePolicyLow"
  policy_type        = "StepScaling"
  resource_id        = "service/${local.ecs_cluster_name}/${aws_ecs_service.this.name}"
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

  depends_on = [aws_appautoscaling_target.ecs_target]
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity = var.autoscaling_max_capacity
  min_capacity = var.autoscaling_min_capacity
  resource_id  = "service/${local.ecs_cluster_name}/${aws_ecs_service.this.name}"

  ### https://docs.aws.amazon.com/autoscaling/application/userguide/application-auto-scaling-service-linked-roles.html
  # role_arn           = "${aws_iam_role.service-autoscaling.arn}"

  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_autoscaling_policy" "scale_policy_high_ec2" {
  name                   = "${title(lower(var.project))}-${title(lower(var.environment))}-${title(lower(var.service))}-ScalePolicyHigh_ec2"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.autoscaling-group[0].name
  count                  = var.launch_type == "FARGATE" ? 0 : 1
}

resource "aws_autoscaling_policy" "scale_policy_low_ec2" {
  name                   = "${title(lower(var.project))}-${title(lower(var.environment))}-${title(lower(var.service))}-ScalePolicyLow_ec2"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.autoscaling-group[0].name
  count                  = var.launch_type == "FARGATE" ? 0 : 1
}

resource "aws_autoscaling_group" "autoscaling-group" {
  name             = "${var.environment}-${var.service}-autoscaling-group"
  max_size         = var.autoscaling_max_capacity
  min_size         = var.autoscaling_min_capacity
  desired_capacity = var.autoscaling_min_capacity

  availability_zones   = var.availability_zones
  vpc_zone_identifier  = var.subnets
  launch_configuration = aws_launch_configuration.launch-configuration_ec2[0].name
  health_check_type    = "ELB"

  tag {
    key                 = "Name"
    value               = "${var.project}-${var.environment}"
    propagate_at_launch = true
  }

  count = var.launch_type == "FARGATE" ? 0 : 1
}

