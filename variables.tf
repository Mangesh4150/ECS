#### Variables For VPC ####

variable "access_key" {
  type = string
}
variable "secret_key" {
  type = string
}
variable "region" {
  type = string
}

#### Variables For Bastion-Server ####

variable "instance_type_bastion" {
  type = string
}
# variable "associate_public_ip" {}

variable "associate_public_ip" {
  type = bool
}

#### Variables for storage account ####
variable "s3_bucket_name" {}
variable "environment" {}
variable "enable_lock" { default = false }
# variable "region" {}

#### Variables for container registry ####
variable "registry_count" {
  type    = number
  default = 2
}

variable "registry_names" {
  type    = list(string)
  default = ["my-terraform-ecr", "my-terraform-ecr-2"]
}

variable "tags" {
  type    = map(string)
  default = { Environment = "QA", Project = "MyApp" }
}

variable "scan_on_push" {
  type    = bool
  default = true
}

variable "image_tag_mutability" {
  type    = string
  default = "IMMUTABLE"
}

variable "retention_days" {
  type    = number
  default = 30
}


#### Variables for ecs ####
variable "cluster_name" {
  type    = string
  default = "my-cluster"
}
