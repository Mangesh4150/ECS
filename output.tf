output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.rds.rds_endpoint
}

output "rds_arn" {
  description = "RDS ARN"
  value       = module.rds.rds_instance_arn
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

# output "ecs_cluster_id" {
#   value = module.ecs.cluster_id
# }