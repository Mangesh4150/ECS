
data "aws_ecs_task_definition" "TD" {
  task_definition = aws_ecs_task_definition.TD.family
}