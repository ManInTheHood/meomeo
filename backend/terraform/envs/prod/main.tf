module "vpc" {
  source              = "../../modules/vpc"
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  public_subnet_cidrs = var.public_subnet_cidrs
}

module "database" {
  source      = "../../modules/database"
  environment = var.environment
  table_name  = var.dynamodb_table_name
}

module "storage" {
  source      = "../../modules/storage"
  environment = var.environment
  bucket_name = var.s3_bucket_name
}

module "compute" {
  source            = "../../modules/compute"
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  app_name          = var.api_app_name
  container_port    = var.container_port
}

module "auth" {
  source                      = "../../modules/auth"
  environment                 = var.environment
  pool_name                   = var.cognito_pool_name
  app_client_name             = var.cognito_app_client_name
  domain_prefix               = var.cognito_domain_prefix
  callback_urls               = var.cognito_callback_urls
  logout_urls                 = var.cognito_logout_urls
  oauth_scopes                = var.cognito_oauth_scopes
  access_token_validity_hours = var.cognito_access_token_validity_hours
  id_token_validity_hours     = var.cognito_id_token_validity_hours
  refresh_token_validity_days = var.cognito_refresh_token_validity_days
}

module "notification" {
  source      = "../../modules/notification"
  environment = var.environment
  app_name    = var.app_name
}

module "api" {
  source       = "../../modules/api"
  environment  = var.environment
  app_name     = var.app_name
  alb_dns_name = module.compute.alb_dns_name
}
