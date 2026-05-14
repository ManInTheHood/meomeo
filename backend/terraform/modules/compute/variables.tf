variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the ALB and ECS will be deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "meomeo-api"
}

variable "container_port" {
  description = "Port the container is listening on"
  type        = number
  default     = 8080
}
