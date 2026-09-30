resource "aws_security_group" "app-sg" {
  name        = "three-tier-app-sg"
  description = "Allow port 8080 traffic from web security group and all outbound traffic"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "TCP"
    security_groups = [var.web_sg_id]
  }
}

resource "aws_instance" "app-ec2" {
  ami                         = var.ami_id
  subnet_id                   = var.app-subnet
  instance_type               = var.instance_type
  key_name                    = var.key_name
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.app-sg.id]

  tags = {
    Name = "app-instance"
  }
}
