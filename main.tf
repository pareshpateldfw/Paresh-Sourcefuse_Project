resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.project_name}-${var.environment}-vpc-main"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment}-public-subnet"
  }
}
resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr_2
  availability_zone = var.availability_zone_2
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment}-public-subnet_2"
  }  
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone
  
  tags = {
    Name = "${var.project_name}-${var.environment}-private-subnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.environment}-aws_internet_gateway-main"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-aws_route_table-public"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id

  
}

resource "aws_ecs_cluster" "main" {
  name = var.ecs_cluster_name

  tags = {
    Name = "${var.project_name}-${var.environment}-aws_ecs_cluster-main"
  }
}

resource "aws_alb" "main" {
  name            = var.alb_name
  internal        = false
  security_groups = [aws_security_group.alb_sg.id]
  subnets         = [aws_subnet.public.id, aws_subnet.public_2.id]

  tags = {
    Name = "${var.project_name}-${var.environment}-aws_alb-main"
  }
}

resource "aws_alb_target_group" "main" {
  name     = "Sourcefuse-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "ip"

  tags = {
    Name = "${var.project_name}-${var.environment}-aws_alb-main"
  }
}


resource "aws_alb_listener" "main" {
  load_balancer_arn = aws_alb.main.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.main.arn
  
  }
}

resource "aws_ecs_task_definition" "nginx" {
  family                   = "nginx"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = var.nginx_image
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "main" {
  name            = "nginx"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.nginx.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = [aws_subnet.public.id]
    security_groups = [aws_security_group.ecs_service_sg.id]
  }
  load_balancer {
    target_group_arn = aws_alb_target_group.main.arn
    container_name   = "nginx"
    container_port   = 80
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-aws_ecs_service-main"
  }
}

resource "aws_s3_bucket" "nginx_bucket" {
  bucket = var.nginx_bucket_name

  tags = {
    Name = "${var.project_name}-${var.environment}-aws_s3_bucket-mainginx_bucket"
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "s3_access_policy" {
  name = "ecsS3AccessPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:GetObject"]
        Resource = "arn:aws:s3:::${var.nginx_bucket_name}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_security_group" "alb_sg" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

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
  
}

resource "aws_security_group" "ecs_service_sg" {
  name        = "ecs_service_sg"
  description = "Allow traffic to ECS service"
  vpc_id      = aws_vpc.main.id

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
}
