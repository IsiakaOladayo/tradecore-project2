# 035 — silent until validate; declares the provider this module depends on.
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
