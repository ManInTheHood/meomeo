output "environment" {
  value = var.environment
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "alb_dns_name" {
  value = module.compute.alb_dns_name
}

output "api_gateway_url" {
  value = module.api.api_gateway_url
}

output "cognito_user_pool_id" {
  value = module.auth.user_pool_id
}

output "cognito_user_pool_arn" {
  value = module.auth.user_pool_arn
}

output "cognito_app_client_id" {
  value = module.auth.user_pool_client_id
}

output "cognito_issuer" {
  value = module.auth.issuer
}

output "cognito_jwks_uri" {
  value = module.auth.jwks_uri
}

output "cognito_domain" {
  value = module.auth.domain
}

output "cognito_callback_urls" {
  value = module.auth.callback_urls
}

output "cognito_logout_urls" {
  value = module.auth.logout_urls
}

output "cognito_oauth_scopes" {
  value = module.auth.oauth_scopes
}

output "sns_topic_arn" {
  value = module.notification.sns_topic_arn
}
