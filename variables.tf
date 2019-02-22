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

variable "minimum_service_capacity" {
  description = "The number of instances of the task definition to place and keep running"
  default     = "1"
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

variable "alb_target_group_arn" {
  description = "ARN of target group"
  type        = "string"
}
