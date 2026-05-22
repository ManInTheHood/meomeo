output "user_pool_id" {
  value = aws_cognito_user_pool.main.id
}

output "user_pool_arn" {
  value = aws_cognito_user_pool.main.arn
}

output "user_pool_client_id" {
  value = aws_cognito_user_pool_client.flutter_app.id
}

output "user_pool_endpoint" {
  value = aws_cognito_user_pool.main.endpoint
}

output "issuer" {
  value = local.issuer
}

output "jwks_uri" {
  value = "${local.issuer}/.well-known/jwks.json"
}

output "domain" {
  value = local.hosted_ui_domain
}

output "domain_prefix" {
  value = aws_cognito_user_pool_domain.main.domain
}

output "callback_urls" {
  value = var.callback_urls
}

output "logout_urls" {
  value = var.logout_urls
}

output "oauth_scopes" {
  value = var.oauth_scopes
}

output "explicit_auth_flows" {
  value = var.explicit_auth_flows
}
