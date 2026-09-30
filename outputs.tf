output "vpc_id" {
  value = module.vpc-module.vpc_id
}

output "web_instance_id" {
  value = module.web-module.web_instance_id
}

output "app_instance_id" {
  value = module.app-module.app_instance_id
}

output "rds_endpoint" {
  value = module.db-module.rds_endpoint
}
