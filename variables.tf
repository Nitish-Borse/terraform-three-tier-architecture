variable "region_name" {
  description = "This variable is used for AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability Zones to use for the three-tier architecture"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for EC2"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "ssh_cidr" {
  description = "CIDR block allowed to access the web server through SSH"
  type        = string
}
