# TradeCore Project 2 - Stack Summary

## Architecture
```
Internet → ALB (public) → ECS Fargate (public subnets) → RDS PostgreSQL (private subnets)
                                                               ↓
                                                          Secrets Manager (DB creds, JWT)
```

## Modules

| Module | Resources | Status |
|--------|-----------|--------|
| **Alb** | ALB, SG, Target Group, HTTP/HTTPS Listeners | Complete |
| **Ecs** | ECS Cluster, Fargate Service, Task Def, IAM Roles, CloudWatch Logs | Complete |
| **Networking** | VPC, IGW, 2 public subnets, 2 private subnets, Route Tables | Complete |
| **SecretsManager** | 5 secrets + secret versions (db_host, db_name, db_user, db_password, jwt_secret) | Complete |
| **Database** | RDS PostgreSQL 15, SG, Subnet Group | Complete |
| **Cognito** | User Pool, App Client | Complete |
| **Amplify** | Amplify App, Branches | Complete |
| **IAM** | OIDC Provider, GitHub Actions Role | Complete |
| **State** | S3 Bucket, DynamoDB Table | Pending |

## Subnet Layout (VPC 10.0.0.0/16)

| Subnet | CIDR | AZ | Purpose |
|--------|------|-----|---------|
| public-0 | 10.0.0.0/24 | af-south-1a | ALB, ECS |
| public-1 | 10.0.1.0/24 | af-south-1b | ALB, ECS |
| private-0 | 10.0.2.0/24 | af-south-1a | RDS |
| private-1 | 10.0.3.0/24 | af-south-1b | RDS |

## Key Decisions
- **No NAT Gateway** - Outbound traffic handled manually
- **Fargate** - Serverless compute (no EC2 instances)
- **awsvpc networking** - Each task gets its own ENI
- **Secrets Manager** - Secrets injected as env vars at runtime
- **Public subnets for ECS** - Tasks have public IPs (per design decision)
- **GitHub Actions OIDC** - No static AWS credentials
- **Terraform state** - S3 backend with DynamoDB locking

## Root Terraform Structure
```
terraform/
├── backend.tf          # S3 backend configuration
├── iam/                # OIDC provider + GitHub Actions role
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── main.tf             # Module wiring
├── outputs.tf          # Root outputs
├── provider.tf         # AWS provider
├── state/              # S3 + DynamoDB (pending creation)
├── variables.tf        # Root variables
└── versions.tf         # Terraform >= 1.16
```

## GitHub Actions Workflow
- **File**: `.github/workflows/terraform.yml`
- **Triggers**: PR to main (plan), push to main (apply)
- **Authentication**: OIDC (no static credentials)
- **Environment**: Requires manual approval

## Missing (To-Do)
| Item | Priority |
|------|----------|
| State infrastructure (S3 + DynamoDB) | High |
| AWS SSO configuration | High |
| GitHub secrets setup | High |
| Test workflow | High |
| OPA policy validation | Medium |
