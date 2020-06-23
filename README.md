# Summary

Terraform module to setup ECS Fargate or ECS EC2.

New variable "launch_type" can be "FARGATE" or "EC2"

## Example

```HCL
module "ecs" {
  source = "github.com/lean-delivery/tf-module-aws-ecs"

  project     = "Project"
  environment = "dev"
  service     = "service-name"

  vpc_id  = "vpc-eizox8ea"
  subnets = ["subnet-sait0aiw", "subnet-op8phee4", "subnet-eego9xoo"]
  availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

  alb_target_group_arn = "arn:aws:elasticloadbalancing:< region >:< account ID >:targetgroup/< target group name >/< target group id >"

  container_port       = "80"

  container_definitions = <<EOF
[
  {
    "name": "first",
    "image": "service-first",
    "cpu": 10,
    "memory": 512,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ]
  }
]
EOF
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| alb\_target\_group\_arn | ARN of target group | string | - | yes |
| container\_cpu | Amount of cpu used by the task | string | `512` | no |
| container\_definitions | Fargate container definition | string | see default value bellow this table | no |
| container\_memory | Amount of memory used by the task | string | `1024` | no |
| container\_name | Name of the container which will be used for ALB configuration | string | `` | no |
| container\_port | exposed port in container | string | `80` | no |
| ecs\_cluster\_id | ID of existing ECS cluster (if want to attach service and etc to existing cluster) | string | `none` | no |
| environment | Environment name is used to identify resources | string | `env` | no |
| health\_check\_grace\_period\_seconds | Seconds to ignore failing load balancer health checks on newly instantiated tasks | string | `30` | no |
| project | Project name is used to identify resources | string | `test` | no |
| service | Service name (will be used as family name in task definition) | string | `SuperService` | no |
| subnets | List of subnets where to run ECS Service | list | - | yes |
| tags | Additional tags for all resources | map | `<map>` | no |
| task\_role\_arn | ARN of IAM role that should be passed into container to access AWS resources from it. | string | `` | no |
| use\_existant\_cluster | Bool statement to declare usage of existant ECS cluster | string | `false` | no |
| instance\_type | Instance type of nodes for ECS with "EC2" launch type  | string | `t2.small` | no |
| launch\_type | Launch type for ECS (FARGATE or EC2 )  | string | `FARGATE` | no |
| volume\_type | Volume type for EC2  | string | `standard` | no |
| volume\_size | Volume size for EC2  | string | `100` | no |
| autoscaling\_min\_capacity | Amount of min running task or EC2 instances | string | `1` | no |
| autoscaling\_max\_capacity | Amount of max running task or EC2 instances  | string | `10` | no |
| autoscaling\_cpu\_high\_threshold | Autoscaling CPU threshold for scale-up  | string | `50` | no |
| autoscaling\_cpu\_low\_threshold | Autoscaling CPU threshold for scale-down  | string | `40` | no |
| availability\_zones | List of availability zones which will be provisined by autoscailing group  | list | `[]` | yes |
| vpc\_id | The ID of VPC | string | - | yes |
| create_security_group | To create or not own security group for service | string | `true` | no |
| security_groups | List of existing security groups to be reused if create_security_group is false | list | `[]` | no |
| assign_public_ip | To assign or not public ip to task | string | `false` | no |
| use_fargate_spot | To use or not spot tasks in Fargate | string | `false` | no |

### Container definitions default value

```HCL
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
```

## Outputs

| Name | Description |
|------|-------------|
| ecs\_cluster\_arn | ECS cluster ARN |
| ecs\_cluster\_id | ECS cluster ID |
| ecs\_cluster\_name | ECS cluster name |
| ecs\_service\_iam\_role\_arn | ARN fo created ECS service |
| ecs\_service\_iam\_role\_name | Name of IAM role that attached to ECS service |
| ecs\_task\_execution\_container\_cpu | Amount of cpu used by the task |
| ecs\_task\_execution\_container\_memory | Amount of memory used by the task |
| ecs\_task\_execution\_iam\_role\_arn | Arn of IAM role that attached to ECS task execution |
| ecs\_task\_execution\_iam\_role\_name | Name of IAM role that attached to ECS task execution |
| security\_group\_description | The description of the security group. |
| security\_group\_id | The ID of the security group. |
| security\_group\_name | The name of the security group. |
| security\_group\_owner\_id | The owner ID. |
| security\_group\_vpc\_id | The VPC ID. |

## License

Apache2.0 Licensed. See [LICENSE](https://github.com/lean-delivery/tf-module-aws-ecs/tree/master/LICENSE) for full details.
