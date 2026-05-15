variable "environment" {
  description = "Environment name"
  type        = string
}

variable "pool_name" {
  description = "Name of the Cognito User Pool"
  type        = string
  default     = "meomeo-user-pool"
}
