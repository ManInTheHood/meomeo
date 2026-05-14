resource "aws_cognito_user_pool" "main" {
  name = "${var.pool_name}-${var.environment}"

  # Cấu hình cho phép User đăng nhập bằng Email
  alias_attributes         = ["email"]
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = true
  }

  schema {
    attribute_data_type = "String"
    name                = "email"
    required            = true
    mutable             = true
  }

  tags = {
    Name        = "${var.pool_name}-${var.environment}"
    Environment = var.environment
  }
}

# Client App dành cho ứng dụng Flutter
resource "aws_cognito_user_pool_client" "flutter_app" {
  name         = "meomeo-flutter-client-${var.environment}"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret = false # App Mobile (Flutter) không nên dùng secret

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}
