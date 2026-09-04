# TradeCore Project 2 - Progress Tracker

## Current State
- All Terraform modules corrected and validated
- Root Terraform configuration created and wired
- GitHub Actions OIDC workflow created
- Terraform validation passes
- **BLOCKED**: Need AWS SSO credentials to proceed with bootstrap

## Completed

### [2026-09-04] Initial Review
- Reviewed all existing modules (Alb, Ecs, Networking, Secrets manager)
- Identified missing root module, missing private app subnets, IAM policy typo

### [2026-09-04] IAM Policy ARN Verified
- Verified `Ecs/main.tf:121` - ARN format is correct
- AWS managed policies use format `arn:aws:iam::aws:policy/...` with empty region/account fields

### [2026-09-04] Verified no to-do/progress tracking in .tf files
- Grepped all .tf files for "todo/to-do/progress" - none found

### [2026-09-04] Created SUMMARY.md
- Temporary file with architecture, modules, subnet layout, and to-do list

### [2026-09-04] Created RDS Module
- Created `Rds/` directory with main.tf, variables.tf, outputs.tf

### [2026-09-04] Module Corrections
- ECS: Renamed private_app_subnet_ids → public_subnet_ids, assign_public_ip=true, CPU=256, Memory=512, Port=4000
- ALB: enable_https=true, port=4000, certificate_arn precondition added
- Database: engine_version=15, common_tags pattern, final_snapshot_identifier added
- Secrets Manager: Renamed to SecretsManager/, added secret_version resources
- Networking: Added common_tags pattern
- Amplify: Removed invalid attributes (total_bandwidth, custom_rules, plugins)
- Cognito: Moved enable_token_revocation and prevent_user_existence_errors to client

### [2026-09-04] Root Terraform Configuration
- Created terraform/ directory with provider, backend, variables, outputs
- Created terraform/iam/ module for GitHub Actions OIDC
- Created .github/workflows/terraform.yml with OIDC authentication
- Wired all modules with proper dependency chain
- Terraform validation passes

### [2026-09-04] Terraform Version
- Updated required_version to ~> 1.16

## To-Do

- [x] Create root module (main.tf, variables.tf, outputs.tf, providers.tf)
- [x] Configure provider (AWS)
- [ ] Configure backend (S3 + DynamoDB state) - PENDING BOOTSTRAP
- [x] Create RDS module
- [x] Create RDS security group
- [x] Wire all modules together in root module
- [ ] Set initial Secrets Manager secret values (requires AWS credentials)
- [x] Add ECS Exec IAM permissions (already in ECS module)
- [ ] Create state infrastructure (S3 bucket + DynamoDB table)
- [ ] Bootstrap Terraform state
- [ ] Configure AWS SSO
- [ ] Add GitHub secrets
- [ ] Test GitHub Actions workflow

## Next Steps (When Resuming)

1. Configure AWS SSO credentials
2. Create terraform/state/ module (S3 + DynamoDB)
3. Bootstrap: `terraform init -backend=false && terraform apply -target=module.state`
4. Migrate: `terraform init -migrate-state`
5. Apply: `terraform apply`
6. Get IAM role ARN: `terraform output github_actions_role_arn`
7. Add GitHub secrets (AWS_ROLE_ARN, DB_PASSWORD, JWT_SECRET, DB_USERNAME, CERTIFICATE_ARN, CONTAINER_IMAGE)
8. Push and test workflow

## Notes
- No NAT Gateway - outbound traffic handled manually
- VPC CIDR: 10.0.0.0/16
- Availability Zones: af-south-1a, af-south-1b
- ECS deployed in public subnets with public IPs (per design decision)
- GitHub repo: IsiakaOladayo/tradecore-project2
