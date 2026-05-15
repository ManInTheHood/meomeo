# Backend Setup Guide (MeoMeo Project)

This document provides step-by-step instructions to initialize the entire AWS virtual infrastructure (LocalStack) on your local machine and deploy the Terraform source code.

## 1. Prerequisites
Before starting, ensure you have the following tools installed on your machine:
- **Docker & Docker Compose**: To run the LocalStack platform.
- **Terraform**: To deploy Infrastructure as Code.
- **Python & pip**: Used to install the AWS CLI.
- **AWS CLI local**: 
  Open your Terminal and run: `pip install awscli-local`

## 2. LocalStack License Activation (Optional but Recommended)
If you have a LocalStack Auth Token, inject it into your environment variables:
- **On Windows (PowerShell)**: `$env:LOCALSTACK_AUTH_TOKEN="your-token-here"`
- **On Mac/Linux**: `export LOCALSTACK_AUTH_TOKEN="your-token-here"`

## 3. Start the Virtual AWS Server (LocalStack)
Open your Terminal, navigate to the `backend` directory, and run Docker:
```bash
cd backend
docker-compose up -d
```
*(Alternatively, use the shortcut if you have `make` installed: `make local-up`)*

Verify that LocalStack is running stably using: `docker ps`. You should see the `localstack_meomeo` container running on port `4566`.

## 4. Deploy Infrastructure with Terraform
Navigate to the Local environment configuration directory:
```bash
cd backend/terraform/envs/local
```

Initialize Terraform (downloads necessary plugins):
```bash
terraform init
```

Deploy the entire infrastructure to LocalStack:
```bash
terraform apply -auto-approve
```
*(This process may take 1-3 minutes to provision the VPC, Database, S3, ECS, API Gateway, etc.)*

## 5. Verify the Setup
Once Terraform reports `Apply complete!`, you can open a new Terminal and use the `awslocal` command to inspect your virtual resources:

- List S3 Buckets: `awslocal s3 ls`
- List DynamoDB Tables: `awslocal dynamodb list-tables`
- List VPCs: `awslocal ec2 describe-vpcs`

---

## Backend Directory Structure
- `docker-compose.yml`: Launches LocalStack.
- `Makefile`: Contains convenient command shortcuts.
- `terraform/modules/`: Contains independent blueprints for each AWS service (VPC, Storage, Database, Compute, Auth, API, Notification).
- `terraform/envs/local/`: Aggregates all modules and deploys them to the localhost environment.