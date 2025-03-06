

data "aws_availability_zone" "az" {
    name                   = var.az
    state                  = "available"
}

data "aws_key_pair" "key" {
    key_name = var.key
}



# data "aws_iam_instance_profile" "instance_profile" {
# #   name = "ec2-instance-profile"
#   name = aws_iam_instance_profile.ec2_instance_profile.name
# }



data "aws_ami" "latest_ubuntu" {
  most_recent = true  

  filter {
    name   = "name"
    values = [var.ami_name_pattern]
  }

  filter {
    name   = "virtualization-type"
    values = [var.ami_virtualization_type]  # Using variable for virtualization type
  }

  filter {
    name   = "state"
    values = ["available"]  # Ensures only available AMIs are fetched
  }

  # owners = [var.ami_owner_id]  # Using variable for owner ID
    owners = ["amazon"]
  
}