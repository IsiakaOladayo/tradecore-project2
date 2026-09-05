# TradeCore Project 2 - Cloud-Native Backend Infrastructure

A production-grade, cloud-native backend infrastructure deployed on AWS using Terraform, featuring containerized microservices, managed PostgreSQL, and CI/CD automation via GitHub Actions with OIDC authentication.

---

## Table of Contents

- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Infrastructure Modules](#infrastructure-modules)
- [Subnet Layout](#subnet-layout)
- [CI/CD Pipeline](#cicd-pipeline)
- [Security](#security)
- [Cost Model](#cost-model)
- [Getting Started](#getting-started)
- [Deployment Guide](#deployment-guide)
- [Key Design Decisions](#key-design-decisions)
- [Project Structure](#project-structure)
- [Environment Variables](#environment-variables)
- [GitHub Secrets](#github-secrets)

---

## Architecture

```
                        ┌─────────────────────────────────────┐
                        │            Internet                 │
                        └──────────────┬──────────────────────┘
                                       │
                                       ▼
                        ┌──────────────────────────────────────┐
                        │     ALB (Application Load Balancer)  │
                        │     Public Subnets - HTTPS :4000     │
                        └──────────────┬───────────────────────┘
                                       │
                                       ▼
                        ┌──────────────────────────────────────┐
                        │     ECS Fargate (Container)          │
                        │     Public Subnets - Public IPs      │
                        │     256 CPU / 512 MiB                │
                        └──────────────┬───────────────────────┘
                                       │
                          ┌────────────┴────────────┐
                          │                         │
                          ▼                         ▼
            ┌─────────────────────┐   ┌──────────────────────────┐
            │  RDS PostgreSQL 15  │   │  Secrets Manager          │
            │  Private Subnets    │   │  DB creds, JWT secret     │
            │  db.t3.micro        │   │  5 secrets                │
            └─────────────────────┘   └──────────────────────────┘
```

### Supporting Services

| Service | Purpose |
|---------|---------|
| **Amazon Cognito** | User authentication and authorization |
| **AWS Amplify** | Frontend hosting and deployment (us-east-1) |
| **Amazon ECR** | Container image registry |
| **Amazon CloudWatch** | Centralized logging and monitoring |
| **Terraform State** | S3 backend with DynamoDB locking |
| **GitHub Actions** | CI/CD pipeline with OIDC (no static credentials) |
| **AWS IAM** | OIDC provider + least-privilege deployment role |

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| **IaC** | Terraform ~> 1.16 |
| **Cloud Provider** | AWS (af-south-1 primary, us-east-1 for Amplify) |
| **Compute** | Amazon ECS Fargate (serverless containers) |
| **Database** | Amazon RDS PostgreSQL 15 |
| **Auth** | Amazon Cognito User Pools |
| **Frontend** | AWS Amplify |
| **CI/CD** | GitHub Actions with OIDC |
| **State Management** | S3 + DynamoDB |
| **Secrets** | AWS Secrets Manager |

---

## Infrastructure Modules

| Module | Directory | Resources | Status |
|--------|-----------|-----------|--------|
| **Networking** | `Networking/` | VPC, Internet Gateway, 2 public subnets, 2 private subnets, route tables | Complete |
| **ALB** | `Alb/` | Application Load Balancer, security group, target group, HTTP/HTTPS listeners | Complete |
| **ECS** | `Ecs/` | ECS cluster, Fargate service, task definition, IAM roles, CloudWatch logs | Complete |
| **RDS** | `Database/` | RDS PostgreSQL 15, security group, DB subnet group | Complete |
| **Secrets Manager** | `SecretsManager/` | 5 secrets (db-host, db-name, db-user, db-password, jwt-secret) | Complete |
| **Cognito** | `Cognito/` | User pool, app client | Complete |
| **Amplify** | `Amplify/` | Amplify app, branches | Complete |
| **IAM** | `terraform/iam/` | OIDC provider, GitHub Actions role with least-privilege policy | Complete |
| **State** | `terraform/state/` | S3 bucket (versioned, encrypted), DynamoDB lock table | Complete |

---

## Subnet Layout

**VPC CIDR:** `10.0.0.0/16`
**Availability Zones:** af-south-1a, af-south-1b

| Subnet | CIDR | AZ | Purpose | Resources |
|--------|------|-----|---------|-----------|
| public-0 | `10.0.0.0/24` | af-south-1a | Public | ALB, ECS tasks |
| public-1 | `10.0.1.0/24` | af-south-1b | Public | ALB, ECS tasks |
| private-0 | `10.0.2.0/24` | af-south-1a | Private | RDS primary |
| private-1 | `10.0.3.0/24` | af-south-1b | Private | RDS standby |

---

## CI/CD Pipeline

**File:** `.github/workflows/terraform.yml`

### Triggers

| Event | Action |
|-------|--------|
| Pull request to `main` (paths: `terraform/**`) | `terraform plan` |
| Push to `main` (paths: `terraform/**`) | `terraform plan` + `terraform apply` |

### Pipeline Stages

```
Checkout → AWS OIDC Auth → Setup Terraform → Init → Format Check → Validate → Plan → Apply
```

### Authentication

Uses **OIDC (OpenID Connect)** — no static AWS credentials stored in GitHub. The workflow assumes an IAM role via GitHub's identity token.

---

## Security

### Least-Privilege IAM

The GitHub Actions IAM role is scoped to only the services this project uses:

| Service | Permissions |
|---------|-------------|
| ECS | Full management (clusters, services, task definitions) |
| ECR | Pull/push images, describe repositories |
| RDS | Describe only (no modifications via CI/CD) |
| Secrets Manager | Full CRUD for secrets |
| CloudWatch Logs | Create/write log groups and streams |
| ALB | Full management (load balancers, target groups, listeners) |
| Cognito | Full management (user pools, app clients) |
| S3 | State bucket management |
| DynamoDB | State lock table management |
| IAM | Pass roles to ECS, manage OIDC provider |
| Amplify | Full management |

### Additional Security Measures

- **No static AWS credentials** — OIDC-based authentication
- **Secrets Manager** — All sensitive values injected as environment variables at runtime
- **RDS encryption** — Storage encrypted with AWS-managed key
- **S3 state encryption** — AES-256 server-side encryption
- **S3 public access blocked** — All public access prohibited on state bucket
- **RDS publicly accessible** — Set to `false`
- **ECS security group** — Inbound only from ALB

---

## Cost Model

**Budget constraint:** <$30 for project duration

| Component | Cost Driver | Est. Monthly |
|-----------|-------------|--------------|
| ECS Fargate | 2 tasks × runtime hours | ~$15-20 |
| ALB | Runs continuously while deployed | ~$5-10 |
| RDS db.t3.micro | Continuous database runtime | ~$5-10 |
| RDS storage | 20GB gp3 storage | ~$2-3 |
| Secrets Manager | 5 secrets | ~$0.40 |
| CloudWatch Logs | Log ingestion/storage | ~$1-2 |
| Amplify | Build/hosting | ~$1-5 |
| ECR | Image storage | ~$0.50 |
| Cognito | Low at capstone scale | ~$0 |
| S3 state | Very small | ~$0.01 |
| DynamoDB state lock | PAY_PER_REQUEST | ~$0.00 |
| **NAT Gateway** | **NOT deployed** | **$0** |
| **Total** | | **~$30-50** |

**Biggest cost driver:** ECS Fargate (2 tasks running continuously)

**Cost-saving decisions:**
- No NAT Gateway (ECS in public subnets with public IPs)
- Single-AZ RDS (no Multi-AZ)
- db.t3.micro instance class
- PAY_PER_REQUEST DynamoDB

---

## Getting Started

### Prerequisites

- AWS CLI v2 installed
- AWS SSO configured with `AdministratorAccess` permission set
- Terraform >= 1.16 (for local development)
- GitHub account with repository access

### 1. Configure AWS SSO

```bash
aws configure sso --profile ENOFE
# Enter:
#   SSO start URL: https://tradecore-dev.awsapps.com/start
#   SSO region: af-south-1
#   Default region: af-south-1
#   Default output: json
```

### 2. Verify Identity

```bash
aws sts get-caller-identity --profile ENOFE
```

### 3. Clone Repository

```bash
git clone https://github.com/IsiakaOladayo/tradecore-project2.git
cd tradecore-project2
```

---

## Deployment Guide

### Phase 1: Bootstrap State Infrastructure

```bash
cd terraform

# Initialize without backend (state not yet created)
terraform init -backend=false

# Preview state infrastructure
terraform plan -target=module.state

# Create state infrastructure (S3 bucket + DynamoDB table)
terraform apply -target=module.state

# Get state bucket and table names
terraform output -target=module.state
```

### Phase 2: Migrate to Remote State

```bash
# Re-initialize with backend configured
terraform init -migrate-state
```

### Phase 3: Configure GitHub Secrets

Add these secrets in GitHub repository settings (Settings → Secrets and variables → Actions):

| Secret | Value | Source |
|--------|-------|--------|
| `AWS_ROLE_ARN` | `terraform output github_actions_role_arn` | After Phase 4 |
| `DB_PASSWORD` | Your chosen database password | User-provided |
| `JWT_SECRET` | Your chosen JWT signing secret | User-provided |
| `DB_USERNAME` | `tradecoreDB` | User-provided |
| `CERTIFICATE_ARN` | ACM certificate ARN | ACM console |
| `CONTAINER_IMAGE` | ECR image URI | ECR console |
| `TF_STATE_BUCKET` | State bucket name | Phase 1 output |
| `TF_LOCK_TABLE` | DynamoDB table name | Phase 1 output |

### Phase 4: Full Deployment

```bash
# Plan full deployment
terraform plan \
  -var="environment=production" \
  -var="db_password=<YOUR_DB_PASSWORD>" \
  -var="jwt_secret=<YOUR_JWT_SECRET>" \
  -var="db_username=tradecoreDB" \
  -var="certificate_arn=<YOUR_CERT_ARN>" \
  -var="container_image=<YOUR_ECR_IMAGE>"

# Apply
terraform apply

# Get GitHub Actions role ARN
terraform output github_actions_role_arn
```

### Phase 5: Test CI/CD

1. Add the `AWS_ROLE_ARN` to GitHub secrets
2. Push a change to any file in `terraform/`
3. Check GitHub Actions for successful plan/apply

---

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| **No NAT Gateway** | Cost-saving: ECS tasks use public subnets with public IPs and Internet Gateway routing |
| **ECS in Public Subnets** | Avoids NAT Gateway cost; tasks receive public IPs for direct internet access |
| **Fargate (not EC2)** | Serverless compute — no EC2 instances to manage, pay per task |
| **awsvpc networking** | Each task gets its own ENI for better network isolation |
| **Secrets Manager injection** | Secrets injected as env vars at runtime, never in code or images |
| **OIDC authentication** | No static AWS credentials in GitHub — uses identity tokens |
| **S3 + DynamoDB state** | Remote state with locking prevents concurrent modifications |
| **Single-AZ RDS** | Cost-saving for capstone; no automatic failover |
| **db.t3.micro** | Smallest instance class for capstone budget |
| **Amplify in us-east-1** | Amplify not available in af-south-1; secondary provider for frontend only |
| **Least-privilege IAM** | GitHub Actions role scoped to only services this project uses |

---

## Project Structure

```
tradecore-project2/
├── .github/
│   └── workflows/
│       └── terraform.yml          # CI/CD pipeline (OIDC)
├── Amplify/                       # Amplify module
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── Alb/                           # Application Load Balancer module
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── Cognito/                       # Cognito User Pool module
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── Database/                      # RDS PostgreSQL module
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── Ecs/                           # ECS Fargate module
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── Networking/                    # VPC + Subnets module
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── SecretsManager/                # Secrets Manager module
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── terraform/                     # Root Terraform configuration
│   ├── backend.tf                 # S3 backend
│   ├── iam/                       # OIDC + GitHub Actions IAM
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── main.tf                    # Module wiring
│   ├── outputs.tf                 # Root outputs
│   ├── provider.tf                # AWS providers (af-south-1 + us-east-1)
│   ├── state/                     # State infrastructure (S3 + DynamoDB)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── variables.tf               # Root variables
│   └── versions.tf                # Terraform >= 1.16
├── progress.md                    # Internal progress tracker (not committed)
├── SUMMARY.md                     # Internal summary (not committed)
└── README.md                      # This file
```

---

## Environment Variables

### ECS Container Environment

| Variable | Source | Description |
|----------|--------|-------------|
| `APP_VERSION` | Hardcoded | Application version |
| `AWS_REGION` | Hardcoded | `af-south-1` |
| `ENVIRONMENT` | Hardcoded | `production` |
| `DB_HOST` | Secrets Manager | RDS endpoint |
| `DB_NAME` | Secrets Manager | Database name |
| `DB_USER` | Secrets Manager | Database username |
| `DB_PASSWORD` | Secrets Manager | Database password |
| `JWT_SECRET` | Secrets Manager | JWT signing secret |

---

## GitHub Secrets

| Secret | Required | Description |
|--------|----------|-------------|
| `AWS_ROLE_ARN` | Yes | IAM role ARN for OIDC authentication |
| `DB_PASSWORD` | Yes | PostgreSQL master password |
| `JWT_SECRET` | Yes | JWT signing secret |
| `DB_USERNAME` | Yes | PostgreSQL master username |
| `CERTIFICATE_ARN` | Yes | ACM certificate ARN for HTTPS |
| `CONTAINER_IMAGE` | Yes | ECR Docker image URI |
| `TF_STATE_BUCKET` | Yes | S3 bucket name for Terraform state |
| `TF_LOCK_TABLE` | Yes | DynamoDB table name for state locking |

---

## License

This project is part of a TradeCore capstone submission.
