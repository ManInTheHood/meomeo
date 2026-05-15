resource "aws_dynamodb_table" "main" {
  name         = "${var.table_name}-${var.environment}"
  billing_mode = "PAY_PER_REQUEST" # Tiết kiệm chi phí cho Dev/Local
  hash_key     = "PK"
  range_key    = "SK"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  tags = {
    Name        = "${var.table_name}-${var.environment}"
    Environment = var.environment
  }
}
