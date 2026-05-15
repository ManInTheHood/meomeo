# 1. Amazon SNS (Dùng để gửi Push Notification qua FCM / APNs)
resource "aws_sns_topic" "main" {
  name = "${var.app_name}-push-notifications-${var.environment}"

  tags = {
    Environment = var.environment
  }
}

# 2. Amazon SQS (Hàng đợi lưu tin nhắn chờ xử lý để gửi qua SNS)
resource "aws_sqs_queue" "main" {
  name                      = "${var.app_name}-notification-queue-${var.environment}"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600 # Lưu tối đa 4 ngày
  receive_wait_time_seconds = 0

  tags = {
    Environment = var.environment
  }
}

# 3. Amazon EventBridge (Nhận event từ hệ thống và đẩy vào SQS)
resource "aws_cloudwatch_event_bus" "main" {
  name = "${var.app_name}-event-bus-${var.environment}"
}

resource "aws_cloudwatch_event_rule" "to_sqs" {
  name           = "route-to-notification-queue-${var.environment}"
  event_bus_name = aws_cloudwatch_event_bus.main.name
  description    = "Gửi các sự kiện thông báo vào SQS Queue"

  # Pattern: Bắt tất cả các sự kiện có detail-type là "SendNotification"
  event_pattern = jsonencode({
    "detail-type" = ["SendNotification"]
  })
}

resource "aws_cloudwatch_event_target" "sqs_target" {
  rule           = aws_cloudwatch_event_rule.to_sqs.name
  event_bus_name = aws_cloudwatch_event_bus.main.name
  target_id      = "SendToSQS"
  arn            = aws_sqs_queue.main.arn
}

# Cấp quyền cho EventBridge được ghi vào SQS
resource "aws_sqs_queue_policy" "main" {
  queue_url = aws_sqs_queue.main.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.main.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_cloudwatch_event_rule.to_sqs.arn
          }
        }
      }
    ]
  })
}
