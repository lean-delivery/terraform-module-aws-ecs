variable "project" {
  type        = "string"
  default     = "test"
  description = "Project name is used to identify resources"
}

variable "environment" {
  type        = "string"
  default     = "env"
  description = "Environment name is used to identify resources"
}

variable "service" {
  description = "Service name (will be used as family name in task definition)"
  default     = "SuperService"
}

variable "use_existant_cluster" {
  description = "Bool statement to declare usage of existant ECS cluster"
  default     = "false"
}

variable "ecs_cluster_id" {
  description = "ID of existing ECS cluster (if want to attach service and etc to existing cluster)"
  default     = "none"
}

variable "ecs_cluster_name" {
  description = "Name of existing ECS cluster (if want to attach service and etc to existing cluster)"
  default     = "none"
}

variable "container_cpu" {
  description = "Amount of cpu used by the task"
  default     = "512"
}

variable "container_port" {
  description = "exposed port in container"
  default     = "80"
}

variable "container_memory" {
  description = "Amount of memory used by the task"
  default     = "1024"
}

variable "health_check_grace_period_seconds" {
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown"
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
  default     = ""
}

variable "aws_secrets_manager_secret_arn" {
  description = "ARN of specific AWS Secrets Manager secret which stores credentials for accessing private docker images registry"
  default     = ""
}

variable "tags" {
  type        = "map"
  description = "Additional tags for all resources"
  default     = {}
}

variable "vpc_id" {
  description = "The ID of VPC"
  type        = "string"
}

variable "subnets" {
  description = "List of subnets where to run ECS Service"
  type        = "list"
}

variable "create_security_group" {
  default = "true"
}

variable "security_groups" {
  type = "list"
}

variable "assign_public_ip" {
  default = "false"
}

variable "alb_target_group_arn" {
  description = "ARN of target group"
  type        = "string"
  default     = "none"
}

variable "key-pair-name" {
  description = "key-pair name for ec2"
  type        = "string"
  default     = "ecs-nodes"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = "string"
  default     = "t2.small"
}

variable "launch_type" {
  description = "Launch type for ECS [ FARGATE | EC2 ]"
  type        = "string"
  default     = "FARGATE"
}

variable "use_fargate_spot" {
  default = "false"
}

variable "volume_type" {
  description = "Volume type for EC2"
  type        = "string"
  default     = "standard"
}

variable "volume_size" {
  description = "Volume size for EC2"
  default     = "100"
}

variable "availability_zones" {
  description = "List of availability zones which will be provisined by autoscailing group"
  type        = "list"
}

variable "autoscaling_min_capacity" {
  description = "Amount of min running task or EC2 instances"
  default     = "1"
}

variable "autoscaling_max_capacity" {
  description = "Amount of max running task or EC2 instances"
  default     = "10"
}

variable "autoscaling_cpu_high_threshold" {
  description = "Autoscaling CPU threshold for scale-up"
  default     = "50"
}

variable "autoscaling_cpu_low_threshold" {
  description = "Autoscaling CPU threshold for scale-down"
  default     = "40"
}
