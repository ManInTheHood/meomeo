variable "environment" {
  description = "Environment name"
  type        = string
}

variable "pool_name" {
  description = "Name of the Cognito User Pool"
  type        = string
  default     = "meomeo-user-pool"
}

variable "app_client_name" {
  description = "Name of the public Cognito app client for mobile/frontend apps"
  type        = string
  default     = "meomeo-flutter-client"
}

variable "domain_prefix" {
  description = "Optional Cognito Hosted UI domain prefix. Defaults to meomeo-auth-<environment>-<account_id>."
  type        = string
  default     = null
}

variable "callback_urls" {
  description = "Allowed OAuth callback URLs for the Cognito Hosted UI app client"
  type        = list(string)
  default     = ["meomeo://auth/callback"]
}

variable "logout_urls" {
  description = "Allowed OAuth logout URLs for the Cognito Hosted UI app client"
  type        = list(string)
  default     = ["meomeo://auth/logout"]
}

variable "oauth_scopes" {
  description = "Allowed OAuth scopes for the public app client"
  type        = list(string)
  default     = ["openid", "email", "profile"]
}

variable "access_token_validity_hours" {
  description = "Access token lifetime in hours"
  type        = number
  default     = 1
}

variable "id_token_validity_hours" {
  description = "ID token lifetime in hours"
  type        = number
  default     = 1
}

variable "refresh_token_validity_days" {
  description = "Refresh token lifetime in days"
  type        = number
  default     = 30
}
