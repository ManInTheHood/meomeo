variable "environment" {
  description = "Environment name"
  type        = string
}

variable "bucket_name" {
  description = "Base name for the S3 bucket"
  type        = string
  default     = "meomeo-storage"
}
