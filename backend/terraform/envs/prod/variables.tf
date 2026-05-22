variable "aws_region" {
  description = "AWS region for this environment"
  type        = string
}

variable "environment" {
  description = "Environment name used for resource naming and tags"
  type        = string
}

variable "app_name" {
  description = "Base application name for shared resources"
  type        = string
}

variable "api_app_name" {
  description = "Application name for API compute resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones for public subnets"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "dynamodb_table_name" {
  description = "Base name for the DynamoDB table"
  type        = string
}

variable "s3_bucket_name" {
  description = "Base name for the S3 bucket"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the API container"
  type        = number
}

variable "cognito_pool_name" {
  description = "Base name for the Cognito User Pool"
  type        = string
}

variable "cognito_app_client_name" {
  description = "Name for the public Cognito app client"
  type        = string
}

variable "cognito_domain_prefix" {
  description = "Cognito Hosted UI domain prefix. Must be globally unique per region."
  type        = string
}

variable "cognito_callback_urls" {
  description = "Allowed OAuth callback URLs for Cognito Hosted UI"
  type        = list(string)
}

variable "cognito_logout_urls" {
  description = "Allowed OAuth logout URLs for Cognito Hosted UI"
  type        = list(string)
}

variable "cognito_oauth_scopes" {
  description = "Allowed OAuth scopes for the public app client"
  type        = list(string)
}

variable "cognito_access_token_validity_hours" {
  description = "Access token lifetime in hours"
  type        = number
}

variable "cognito_id_token_validity_hours" {
  description = "ID token lifetime in hours"
  type        = number
}

variable "cognito_refresh_token_validity_days" {
  description = "Refresh token lifetime in days"
  type        = number
}
