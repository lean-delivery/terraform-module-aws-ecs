variable "project" {
  type        = "string"
  default     = "project"
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
