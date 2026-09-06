output "bucket_name" {
  description = "Name of the TradeCore application data S3 bucket"
  value       = aws_s3_bucket.app_data.bucket
}

output "bucket_arn" {
  description = "ARN of the TradeCore application data S3 bucket"
  value       = aws_s3_bucket.app_data.arn
}

output "bucket_id" {
  description = "ID of the TradeCore application data S3 bucket"
  value       = aws_s3_bucket.app_data.id
}
