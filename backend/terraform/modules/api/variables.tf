variable "environment" {
  description = "Environment name"
  type        = string
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "meomeo"
}

variable "alb_dns_name" {
  description = "DNS name of the Application Load Balancer to route traffic to"
  type        = string
}
