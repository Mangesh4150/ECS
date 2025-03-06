# data "aws_ami" "latest_ubuntu" {
#   most_recent = true # Get the latest AMI

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-20.04-amd64-server-*"] # Adjust version if needed
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = ["099720109477"] # Canonical's AWS Account ID for official Ubuntu AMIs
# }
