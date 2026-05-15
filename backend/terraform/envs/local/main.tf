provider "aws" {
  region                      = "ap-southeast-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    ec2          = "http://localhost:4566"
    dynamodb     = "http://localhost:4566"
    s3           = "http://localhost:4566"
    cognito-idp  = "http://localhost:4566"
    sqs          = "http://localhost:4566"
    sns          = "http://localhost:4566"
    events       = "http://localhost:4566"
    apigatewayv2 = "http://localhost:4566"
  }
}

module "vpc" {
  source      = "../../modules/vpc"
  environment = "local"
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

module "database" {
  source      = "../../modules/database"
  environment = "local"
}

module "storage" {
  source      = "../../modules/storage"
  environment = "local"
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
  environment = "local"
}

module "notification" {
  source      = "../../modules/notification"
  environment = "local"
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
