# Configure during terraform init:
#
#   terraform init \
#     -backend-config="bucket=<TF_STATE_BUCKET>" \
#     -backend-config="key=tradecore/<ENVIRONMENT>/terraform.tfstate" \
#     -backend-config="region=<AWS_REGION>" \
#     -backend-config="use_lockfile=true"
#
# S3 native locking (use_lockfile) replaced the deprecated dynamodb_table
# parameter. The DynamoDB table is retained but no longer consulted.

terraform {
  backend "s3" {
    encrypt = true
  }
}
