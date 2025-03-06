# resource "aws_lb" "LB" {
#   name               = "LB"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.SG.id]
#   subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

#   tags = {
#     Name = "LB"
#   }
# }

# resource "aws_alb_listener" "Listener" {
#   load_balancer_arn = aws_lb.LB.id
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     target_group_arn = aws_lb_target_group.TG.id
#     type             = "forward"
#   }
# }

# resource "aws_lb_target_group" "TG" {
#   name        = "TG"
#   port        = "80"
#   protocol    = "HTTP"
#   target_type = "ip"
#   vpc_id      = aws_vpc.vpc.id

#   tags = {
#     Name = "TG"
#   }
# }