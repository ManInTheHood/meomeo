output "sns_topic_arn" {
  value = aws_sns_topic.main.arn
}

output "sqs_queue_url" {
  value = aws_sqs_queue.main.url
}

output "event_bus_name" {
  value = aws_cloudwatch_event_bus.main.name
}
