output "web_sg_id" {
  value = aws_security_group.web-sg.id
}

output "web_instance_id" {
  value = aws_instance.web-ec2.id
}
