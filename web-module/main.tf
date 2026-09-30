#Create Security Groups
resource "aws_security_group" "web-sg" {
  name        = "three-tier-web-sg"
  description = "Allow SSH, HTTP and HTTPS traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = [var.ssh_cidr]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Ec2 Instance Creation
resource "aws_instance" "web-ec2" {
  ami                         = var.ami_id
  subnet_id                   = var.web-subnet
  instance_type               = var.instance_type
  key_name                    = var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.web-sg.id]

  tags = {
    Name = "web-instance"
  }
}
