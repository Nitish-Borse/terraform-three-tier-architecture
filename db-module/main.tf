resource "aws_security_group" "db-sg" {
  name        = "three-tier-db-sg"
  description = "Allow MySQL 3306 traffic from app security group and all outbound traffic"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "TCP"
    security_groups = [var.app_sg_id]
  }
}

resource "aws_db_instance" "db-rds" {
  allocated_storage      = 10
  db_name                = "threetierdb"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = var.db_username
  password               = var.db_password
  publicly_accessible    = false
  storage_encrypted      = true
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.mysubnetgp.name
  vpc_security_group_ids = [aws_security_group.db-sg.id]
}

resource "aws_db_subnet_group" "mysubnetgp" {
  name = "three-tier-db"
  subnet_ids = [
    var.db-subnet,
    var.db-subnet-2
  ]

  tags = {
    Name = "three-tier-db"
  }
}
