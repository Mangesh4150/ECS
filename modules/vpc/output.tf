output "vpc_id" {
  value = aws_vpc.myVPC.id
}

output "public_subnet_1" {
  value = aws_subnet.public_subnet_1.id
}

output "public_subnet_2" {
  value = aws_subnet.public_subnet_2.id
}

output "database_subnet_1" {
  value = aws_subnet.database_subnet_1.id
}

output "private_subnet_1" {
  value = aws_subnet.private_subnet_1.id
}

output "private_subnets" {
  value = [aws_subnet.database_subnet_1.id, aws_subnet.private_subnet_1.id]
}

output "security_group_id" {
  description = "Security Group ID for EC2 instance"
  value       = aws_security_group.sg.id
}










# output "eks_security_group_id" {
#   description = "Security Group ID for EKS cluster"
#   value       = aws_security_group.sg.id  # Replace with your actual SG resource name
# }


# output "db_subnet_group_name" {
#   description = "The name of the DB subnet group"
#   value       = aws_db_subnet_group.this.name  # Ensure this matches your actual resource
# }

# output "security_group_ids" {
#   description = "List of security group IDs"
#   value       = aws_security_group.vpc_sg[*].id  # Adjust based on your SG resource name
# }