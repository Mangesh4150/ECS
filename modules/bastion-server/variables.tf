# variable "ami_id" {
#   type    = string
#   default = "ami-0ed9277fb7eb570c9"
# }
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
variable "associate_public_ip" {
  type    = bool
  default = true
}
variable "az" {
  type    = string
  default = "ap-south-1a"
}
variable "disable_api_termination" {
  type    = bool
  default = false
}
variable "security_group_id" {
  description = "Security Group ID for EC2"
  type        = string
}
variable "volume_size" {
  type    = number
  default = 10
}
variable "application" {
  type    = string
  default = "tcw"
}
variable "organization" {
  type    = string
  default = "thecloudworld"
}
variable "instance_profile" {
  type    = string
  default = "ec2-instance-new-profile"
}
variable "key" {
  type    = string
  default = "dev-account"
}
variable "ami_name_pattern" {
  description = "The name pattern for the Ubuntu AMI"
  type        = string
  default     = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
}

variable "ami_virtualization_type" {
  description = "The virtualization type for the AMI"
  type        = string
  default     = "hvm"
}

variable "subnet_id" {
  description = "The subnet ID to launch the bastion host"
  type        = string
}


# variable "ami_owner_id" {
#   description = "The AWS account ID of the AMI owner"
#   type        = string
#   default     = "099720109477"  # Canonical's AWS Account ID
# }





# variable "sg" {
#   type    = list(any)
#   default = ["sg-0858149edde4ae5ae"]
# }
# variable "subnet_id" {
#   type    = string
#   default = "subnet-03a2ea8c56ec8a1f2"
# }



