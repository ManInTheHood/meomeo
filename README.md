# Backend Setup Guide (MeoMeo Project)

This document provides step-by-step instructions to deploy the entire AWS infrastructure for the MeoMeo application to your AWS environment using Terraform.

## 1. Prerequisites
Before starting, ensure you have the following tools installed on your machine:
- **Terraform**: To deploy Infrastructure as Code.
- **AWS CLI**: To configure your AWS credentials.

Configure your AWS credentials by running:
```bash
aws configure
```

## 2. Deploy Infrastructure with Terraform

Terraform environments are split by directory. Each environment has its own
configuration and local state by default:

- `backend/terraform/envs/dev`
- `backend/terraform/envs/prod`

For real production usage, configure a remote backend with a separate state key
per environment before running `terraform apply`.

### Dev

Navigate to the Dev environment configuration directory:
```bash
cd backend/terraform/envs/dev
```

Initialize Terraform (downloads necessary plugins):
```bash
terraform init
```

Deploy the entire infrastructure to AWS:
```bash
terraform apply -auto-approve
```
*(This process may take a few minutes to provision the VPC, Database, S3, ECS, API Gateway, etc.)*

### Prod

Review `backend/terraform/envs/prod/terraform.tfvars` before planning or
applying production. Update callback/logout URLs and any resource naming values
to match the real production app.

```bash
cd backend/terraform/envs/prod
terraform init
terraform validate
terraform plan
```

Run `terraform apply` only after production state isolation and final values are
confirmed.

## 3. Verify the Setup
Once Terraform reports `Apply complete!`, you can use the `aws` command to inspect your resources:

- List S3 Buckets: `aws s3 ls`
- List DynamoDB Tables: `aws dynamodb list-tables`
- List VPCs: `aws ec2 describe-vpcs`

---

## Backend Directory Structure
- `Makefile`: Contains convenient command shortcuts.
- `terraform/modules/`: Contains independent blueprints for each AWS service (VPC, Storage, Database, Compute, Auth, API, Notification).
- `terraform/envs/dev/`: Aggregates all modules and deploys them to the dev AWS environment.
- `terraform/envs/prod/`: Aggregates all modules and deploys them to the prod AWS environment.
