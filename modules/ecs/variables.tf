# variable "vpc_id" {
#   type    = string 
# }

# variable "cluster_name" {
#   type    = string 
#   default = "my-cluster"
# }

variable "cluster_id" {
  description = "The ECS cluster ID where services should be deployed"
  type        = string
}

variable "service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where ECS will be deployed"
  type        = string
}

variable "subnets" {
  description = "List of public subnets for ECS tasks"
  type        = list(string)
}

variable "image_url" {
  description = "ECR image URL"
  type        = string
}

variable "sg_names" {
  type = map(string)
  default = {
    ecs-service1 = "Security group for service1"
    ecs-service2 = "Security group for service2"
  }
}
