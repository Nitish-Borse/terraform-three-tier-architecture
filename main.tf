terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "nitish-borse-terraform-state-2026"
    key          = "terraform-three-tier-architecture/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = var.region_name
}

#Creating AWS EC2 Instance Key Pair
resource "aws_key_pair" "mytf_key_pair" {
  key_name   = "mytf-key-pair"
  public_key = file(pathexpand("~/.ssh/mytf_key_pair.pub"))
}

module "vpc-module" {
  source             = "./vpc-module"
  availability_zones = var.availability_zones
}

module "web-module" {
  source        = "./web-module"
  vpc_id        = module.vpc-module.vpc_id
  web-subnet    = module.vpc-module.web-subnet
  key_name      = aws_key_pair.mytf_key_pair.key_name
  ami_id        = var.ami_id
  instance_type = var.instance_type
  ssh_cidr      = var.ssh_cidr
}

module "app-module" {
  source        = "./app-module"
  vpc_id        = module.vpc-module.vpc_id
  app-subnet    = module.vpc-module.app-subnet
  key_name      = aws_key_pair.mytf_key_pair.key_name
  ami_id        = var.ami_id
  instance_type = var.instance_type
  web_sg_id     = module.web-module.web_sg_id
}

module "db-module" {
  source      = "./db-module"
  vpc_id      = module.vpc-module.vpc_id
  db-subnet   = module.vpc-module.db-subnet
  db-subnet-2 = module.vpc-module.db-subnet-2
  db_username = var.db_username
  db_password = var.db_password
  app_sg_id   = module.app-module.app_sg_id
}
