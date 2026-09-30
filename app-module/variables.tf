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

variable "web_sg_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "app-subnet" {
  type = string
}
