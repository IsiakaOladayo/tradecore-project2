# =========================================================
# TRADECORE - REMOTE STATE BACKEND
# =========================================================
#
# Configure during terraform init:
#
#   terraform init \
#     -backend-config="bucket=<TF_STATE_BUCKET>" \
#     -backend-config="key=tradecore/<ENVIRONMENT>/terraform.tfstate" \
#     -backend-config="region=<AWS_REGION>" \
#     -backend-config="dynamodb_table=<TF_LOCK_TABLE>"
#

terraform {
  backend "s3" {
    encrypt = true
  }
}
