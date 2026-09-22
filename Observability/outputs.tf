output "alarm_topic_arn" {
  description = "SNS topic that receives alarm notifications."
  value       = aws_sns_topic.alarms.arn
}

output "budget_name" {
  description = "Name of the project cost budget."
  value       = aws_budgets_budget.project.name
}
