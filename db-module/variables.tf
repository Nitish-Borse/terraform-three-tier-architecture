variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "app_sg_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "db-subnet" {
  type = string
}

variable "db-subnet-2" {
  type = string
}
