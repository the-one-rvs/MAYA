resource "aws_ecs_cluster" "main" {
  name = "maya-cluster"
  depends_on = [
    aws_vpc.maya_vpc,
    aws_security_group.ecs_sg
  ]
}

resource "aws_ecs_task_definition" "app" {
  family                   = "maya-app"
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                     = 256
  memory                  = 512

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = var.image
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = 80
        }
      ]
      environment = [
        {
          name  = "PORT"
          value = var.container_port
        }
      ]
    }
  ])
  depends_on = [aws_ecs_cluster.main]
}
resource "aws_ecs_service" "app" {
  name            = "maya-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.quasar_subnet_1.id, aws_subnet.quasar_subnet_2.id]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
  depends_on = [aws_ecs_task_definition.app]
}


