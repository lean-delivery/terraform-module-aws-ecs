variable "project" {
  description = "Project name is used to identify resources"
  type        = string
  default     = "test"
}

variable "environment" {
  description = "Environment name is used to identify resources"
  type        = string
  default     = "env"
}

variable "service" {
  description = "Service name (will be used as family name in task definition)"
  type        = string
  default     = "SuperService"
}

variable "use_existant_cluster" {
  description = "Bool statement to declare usage of existant ECS cluster"
  type        = bool
  default     = false
}

variable "ecs_cluster_id" {
  description = "ID of existing ECS cluster (if want to attach service and etc to existing cluster)"
  type        = string
  default     = "none"
}

variable "ecs_cluster_name" {
  description = "Name of existing ECS cluster (if want to attach service and etc to existing cluster)"
  type        = string
  default     = "none"
}

variable "container_cpu" {
  description = "Amount of cpu used by the task"
  type        = string
  default     = "512"
}

variable "container_port" {
  description = "exposed port in container"
  type        = number
  default     = 80
}

variable "container_memory" {
  description = "Amount of memory used by the task"
  type        = string
  default     = "1024"
}

variable "container_name" {
  description = "Defines container name which will be used as target in ALB target group. If not set var.project-var.service value will be used."
  type = string
  default     = ""
}

variable "health_check_grace_period_seconds" {
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown"
  type        = string
  default     = "30"
}

variable "container_definitions" {
  description = "Fargate container definition"

  default = <<DEFINITION
[
  {
    "name": "SuperService-env",
    "cpu": 512,
    "memory": 512,
    "image": "nginx:alpine",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ]
  }
]
DEFINITION
}

variable "task_role_arn" {
  description = "ARN of IAM role that should be passed into container to access AWS resources from it."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map
  default     = {}
}

variable "vpc_id" {
  description = "The ID of VPC"
  type        = string
}

variable "subnets" {
  description = "List of subnets where to run ECS Service"
  type        = list
}

variable "create_security_group" {
  type = bool
  default = true
}

variable "security_groups" {
  type = list
  default = []
}

variable "assign_public_ip" {
  type    = bool
  default = false
}

variable "alb_target_group_arn" {
  description = "ARN of target group"
  type        = string
  default     = "none"
}

variable "key-pair-name" {
  description = "key-pair name for ec2"
  type        = string
  default     = "ecs-nodes"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.small"
}

variable "launch_type" {
  description = "Launch type for ECS [ FARGATE | EC2 ]"
  type        = string
  default     = "FARGATE"
}

variable "use_fargate_spot" {
  type    = bool
  default = false
}

variable "volume_type" {
  description = "Volume type for EC2"
  type        = string
  default     = "standard"
}

variable "volume_size" {
  description = "Volume size for EC2"
  type        = string
  default     = "100"
}

variable "availability_zones" {
  description = "List of availability zones which will be provisined by autoscailing group"
  type        = list
}

variable "autoscaling_min_capacity" {
  description = "Amount of min running task or EC2 instances"
  type        = string
  default     = "1"
}

variable "autoscaling_max_capacity" {
  description = "Amount of max running task or EC2 instances"
  type        = string
  default     = "10"
}

variable "autoscaling_cpu_high_threshold" {
  description = "Autoscaling CPU threshold for scale-up"
  type        = string
  default     = "50"
}

variable "autoscaling_cpu_low_threshold" {
  description = "Autoscaling CPU threshold for scale-down"
  type        = string
  default     = "40"
}
