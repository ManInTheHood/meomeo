resource "aws_s3_bucket" "main" {
  bucket = "${var.bucket_name}-${var.environment}"

  tags = {
    Name        = "${var.bucket_name}-${var.environment}"
    Environment = var.environment
  }
}

# Cấu hình CORS để App Flutter có thể upload/download qua Presigned URL
resource "aws_s3_bucket_cors_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    allowed_origins = ["*"] # Trong thực tế (Prod) nên giới hạn lại domain
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}
