provider "aws" {
  region = "ap-southeast-1"
}

module "vpc" {
  source      = "../../modules/vpc"
  environment = "dev"
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

module "database" {
  source      = "../../modules/database"
  environment = "dev"
}

module "storage" {
  source      = "../../modules/storage"
  environment = "dev"
}

module "compute" {
  source            = "../../modules/compute"
  environment       = "local"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  app_name          = "meomeo-api"
  container_port    = 80
}

module "auth" {
  source      = "../../modules/auth"
  environment = "dev"
}

module "notification" {
  source      = "../../modules/notification"
  environment = "dev"
}

module "api" {
  source       = "../../modules/api"
  environment  = "local"
  alb_dns_name = module.compute.alb_dns_name
}

output "alb_dns_name" {
  value = module.compute.alb_dns_name
}

output "cognito_user_pool_id" {
  value = module.auth.user_pool_id
}

output "sns_topic_arn" {
  value = module.notification.sns_topic_arn
}

output "api_gateway_url" {
  value = module.api.api_gateway_url
}
