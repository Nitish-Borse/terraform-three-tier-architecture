output "app_sg_id" {
  value = aws_security_group.app-sg.id
}

output "app_instance_id" {
  value = aws_instance.app-ec2.id
}
