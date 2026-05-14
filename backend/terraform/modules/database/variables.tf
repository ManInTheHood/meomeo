variable "environment" {
  description = "Environment name"
  type        = string
}

variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = "meomeo-main-table"
}
