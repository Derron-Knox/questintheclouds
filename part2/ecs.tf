resource "aws_ecr_repository" "quest_repo" {
  name = "quest-repo"
}

resource "aws_ecs_cluster" "quest_cluster" {
  name = "quest-cluster"
}

resource "aws_ecs_task_definition" "my_first_task" {
  family                   = "quest-task"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "quest-task",
      "image": "${aws_ecr_repository.quest_repo.repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_service" "my_first_service" {
  name            = "my-first-service"
  cluster         = aws_ecs_cluster.quest_cluster.id
  task_definition = aws_ecs_task_definition.my_first_task.arn
  launch_type     = "FARGATE"
  desired_count   = 3

  network_configuration {
    security_groups  = [aws_security_group.rearc-quest-ecs-security-group.id]
    subnets          = [aws_subnet.rearc-quest-subnet-1.id, aws_subnet.rearc-quest-subnet-2.id, aws_subnet.rearc-quest-subnet-3.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.rearc-quest-target-group.id
    container_name   = "quest-task"
    container_port   = "3000"
  }
}
