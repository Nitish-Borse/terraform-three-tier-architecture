variable "ami_id" {
  type        = string
  description = "AMI ID for the EC2 instance"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "key_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "web-subnet" {
  type = string
}

variable "ssh_cidr" {
  description = "CIDR block allowed to access the web server through SSH"
  type        = string
}
