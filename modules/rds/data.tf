data "aws_vpc" "vpc_available" {
  filter {
    name   = "tag:Name"
    values = ["tcw_vpc"]
  }
}
data "aws_subnets" "available_db_subnet" {
  
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc_available.id]
  }
  filter {
    name   = "tag:Name"
    values = ["tcw_database_subnet_az_1*", "tcw_private_subnet_az_1*"] 
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}
data "aws_security_group" "tcw_sg" {
  filter {
    name   = "tag:Name"
    values = ["tcw_security_group"]
  }
}