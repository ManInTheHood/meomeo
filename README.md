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