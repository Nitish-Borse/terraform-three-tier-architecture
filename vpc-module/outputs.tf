output "vpc_id" {
  value = aws_vpc.three-tier-vpc.id
}

output "web-subnet" {
  value = aws_subnet.web-subnet.id
}

output "app-subnet" {
  value = aws_subnet.app-subnet.id
}

output "db-subnet" {
  value = aws_subnet.db-subnet.id
}

output "db-subnet-2" {
  value = aws_subnet.db-subnet-2.id
}
