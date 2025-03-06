################################################################################
# VPC
################################################################################

resource "aws_vpc" "myVPC" {
  cidr_block           = var.cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags = {
    Name = var.vpc_name
  }
}

###############################################################################
# Internet Gateway
###############################################################################

resource "aws_internet_gateway" "myIGW" {

  vpc_id = aws_vpc.myVPC.id
  tags = {
    "Name" = var.igw_tag
  }
}

###############################################################################
# Create an Elastic IP for the NAT Gateway
###############################################################################

resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "NAT-Gateway-EIP"
  }
}

################################################################################
# Public subnet
################################################################################

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.myVPC.id
  cidr_block              = var.public_subnets_cidr_1
  availability_zone       = data.aws_availability_zones.available_1.names[0]
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name = var.public_subnet_tag_1
  }
}
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.myVPC.id
  cidr_block              = var.public_subnets_cidr_2
  availability_zone       = data.aws_availability_zones.available_1.names[1]
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name = var.public_subnet_tag_2
  }
}

################################################################################
# Create a NAT Gateway in One of Your Public Subnets
################################################################################

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id  # Attach to one of the public subnets

  tags = {
    Name = "NAT-Gateway"
  }
}

################################################################################
# Database subnet
################################################################################

resource "aws_subnet" "database_subnet_1" {
  vpc_id                  = aws_vpc.myVPC.id
  cidr_block              = var.database_subnets_cidr_1
  availability_zone       = data.aws_availability_zones.available_1.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = var.database_subnet_tag_1
  }
}

################################################################################
# Private subnet
################################################################################

resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.myVPC.id
  cidr_block              = var.private_subnets_cidr_1
  availability_zone       = data.aws_availability_zones.available_1.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name = var.private_subnet_tag_1
  }
}

################################################################################
# Publiс routes
################################################################################

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.myVPC.id
  tags = {
    Name = var.public_route_table_tag
  }
}
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.myIGW.id
}

################################################################################
# Database route table
################################################################################

resource "aws_route_table" "database_route_table" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = var.database_route_table_tag
  }
}


################################################################################
# Create a Route Table for Private Subnets
################################################################################

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = var.private_route_table_tag
  }
}
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}


################################################################################
# Route table association with subnets
################################################################################

resource "aws_route_table_association" "public_route_table_association_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}
resource "aws_route_table_association" "public_route_table_association_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}
resource "aws_route_table_association" "database_route_table_association_1" {
  subnet_id      = aws_subnet.database_subnet_1.id
  route_table_id = aws_route_table.database_route_table.id
}

resource "aws_route_table_association" "private_route_table_association_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}
###############################################################################
# Security Group
###############################################################################

resource "aws_security_group" "sg" {
  name        = "tcw_security_group"
  description = "Allow specific traffic"
  vpc_id      = aws_vpc.myVPC.id

  ingress = [
    {
      description      = "Allow HTTP traffic"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []      # Empty list for IPv6 CIDR blocks
      prefix_list_ids  = null    # No prefix lists
    #   security_groups  = [aws_security_group.sg.id] # Reference itself
      security_groups  = null    # No security groups
      self             = null    # No self-referencing
    },
    {
      description      = "Allow HTTPS traffic"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = null
    #   security_groups  = [aws_security_group.sg.id] # Reference itself
      security_groups  = null
      self             = null
    },
    {
      description      = "Allow SSH traffic"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    #   cidr_blocks      = ["115.246.26.0/24"] # Replace with your specific IP range
    #   security_groups  = [aws_security_group.sg.id] # Reference itself
      ipv6_cidr_blocks = []
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    },
    {
      description      = "Allow FTP traffic"
      from_port        = 21
      to_port          = 21
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    #   cidr_blocks      = ["115.246.26.0/24"] # Replace with your specific IP range
    #   security_groups  = [aws_security_group.sg.id] # Reference itself
      ipv6_cidr_blocks = []
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]

  egress = [
    {
      description      = "Allow all outbound traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]

  tags = {
    Name = "tcw_security_group"
  }
}
