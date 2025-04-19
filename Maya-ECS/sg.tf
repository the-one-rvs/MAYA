resource "aws_security_group" "ecs_sg" {
  name        = "maya-ecs-sg"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.maya_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  depends_on = [aws_vpc.maya_vpc]
}