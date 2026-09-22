# 035 — root passes an explicit provider, which needs a declaration here.
terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws]
    }
  }
}
