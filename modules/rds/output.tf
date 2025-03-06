output "subnet_data" {
  value = data.aws_subnets.available_db_subnet.ids
}
output "rds_endpoint" {
  value = aws_db_instance.db_instance.endpoint
}

output "rds_instance_arn" {
  value = aws_db_instance.db_instance.arn
}
