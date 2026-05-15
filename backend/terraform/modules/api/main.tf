# 1. Khởi tạo API Gateway (HTTP API - Nhanh và rẻ hơn REST API)
resource "aws_apigatewayv2_api" "main" {
  name          = "${var.app_name}-gateway-${var.environment}"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization"]
    max_age       = 300
  }

  tags = {
    Environment = var.environment
  }
}

# 2. Tạo kết nối (Integration) từ API Gateway trỏ thẳng vào Application Load Balancer
resource "aws_apigatewayv2_integration" "alb" {
  api_id             = aws_apigatewayv2_api.main.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = "http://${var.alb_dns_name}"
  integration_method = "ANY"
  connection_type    = "INTERNET" # ALB hiện tại đang ở Public Subnet
}

# 3. Tạo Route (Bắt tất cả các URL và đẩy qua ALB)
resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.alb.id}"
}

# 4. Tạo Stage (Môi trường triển khai tự động)
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true
}
