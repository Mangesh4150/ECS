resource "aws_instance" "instance" {
  # ami                         = var.ami_id 
  ami                       = data.aws_ami.latest_ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.associate_public_ip
  availability_zone           = data.aws_availability_zone.az.id
  disable_api_termination     = var.disable_api_termination
#   iam_instance_profile        = data.aws_iam_instance_profile.instance_profile.role_name
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
  key_name                    = data.aws_key_pair.key.key_name
#   security_groups             = null
#   security_groups             = [var.security_group_id]  # Using Security Group from VPC module
  vpc_security_group_ids      = [var.security_group_id]
  hibernation                 = false
  credit_specification {
    cpu_credits = "standard"
  }
  root_block_device {
    delete_on_termination = true
    encrypted             = false
    volume_size           = var.volume_size
    volume_type           = "gp2"
    tags = {
      Name         = "ec2_production"
      application  = var.application
      organization = var.organization
    }
  }
  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
  tags = {
    Name         = "bastion-server"
    application  = var.application
    organization = var.organization
  }
}

resource "aws_ebs_volume" "ebs_volume" {
  availability_zone = data.aws_availability_zone.az.id
  size              = var.volume_size
#   snapshot_id       = null
  type              = "gp2"
  tags = {
    Name         = "ebs_volume"
    application  = var.application
    organization = var.organization
  }
}

resource "aws_volume_attachment" "ebs_attachment" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.ebs_volume.id
  instance_id = aws_instance.instance.id
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# resource "aws_iam_policy_attachment" "ec2_policy_attach" {

resource "aws_iam_role_policy_attachment" "ec2_policy_attach" {
#   name       = "ec2-policy-attachment"
  role      = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"  # Modify as per your requirement
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
#   name = "ec2-instance-new-profile"
    name = var.instance_profile
    role = aws_iam_role.ec2_role.name
}
