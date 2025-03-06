output "lb_dns_name" {
  value = aws_lb.LB.dns_name
}

# output "cluster_id" {
#   value = aws_ecs_cluster.ECS.id
# }