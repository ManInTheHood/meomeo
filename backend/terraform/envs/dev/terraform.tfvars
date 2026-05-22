aws_region  = "ap-southeast-1"
environment = "dev"

app_name     = "meomeo"
api_app_name = "meomeo-api"

vpc_cidr            = "10.0.0.0/16"
availability_zones  = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

dynamodb_table_name = "meomeo-main-table"
s3_bucket_name      = "meomeo-storage"

container_port = 80

cognito_pool_name       = "meomeo-user-pool"
cognito_app_client_name = "meomeo-flutter-client"
cognito_domain_prefix   = null
cognito_callback_urls = [
  "meomeo://auth/callback",
  "http://localhost:3000/auth/callback"
]
cognito_logout_urls = [
  "meomeo://auth/logout",
  "http://localhost:3000/auth/logout"
]
cognito_oauth_scopes                = ["openid", "email", "profile"]
cognito_access_token_validity_hours = 1
cognito_id_token_validity_hours     = 1
cognito_refresh_token_validity_days = 30
