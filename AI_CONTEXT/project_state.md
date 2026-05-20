# Project State Context

**Last Updated:** 2026-05-15

## 1. Current Status
The entire AWS infrastructure architecture for the **MeoMeo** application has been successfully codified using Terraform (Infrastructure as Code) and is deployed to the AWS dev environment.

The following modules have been implemented and logically linked in the `backend/terraform/modules/` directory:
1. **VPC (Core Network):** Private virtual network with an Internet Gateway and 3 Public Subnets (Multi-AZ).
2. **Storage:** S3 Bucket (`meomeo-storage-dev`) supporting direct file Uploads/Downloads via Presigned URLs (CORS enabled for the App).
3. **Database:** DynamoDB Table (`meomeo-main-table-dev`) configured with cost-effective Pay-per-request billing.
4. **Compute:** 
   - Application Load Balancer (ALB).
   - ECS Cluster & Task Definition running on Serverless Fargate (currently utilizing a temporary `nginx` container as a placeholder).
5. **Auth:** Cognito User Pool & App Client facilitating Email-based Login/Registration for the Flutter application.
6. **Notification:** EventBridge -> SQS -> SNS system primed for broadcasting Push Notifications to mobile devices (FCM/APNs).
7. **API Gateway:** HTTP Proxy gateway routing traffic directly to the Application Load Balancer.

## 2. Next Steps / To Implement

These are the pending items that the AI and Developer need to implement in upcoming sessions:

### Phase 2A: Backend Source Code Development
- [ ] Initialize the actual API source code (Node.js/Python/Go) within the `backend/src/` directory.
- [ ] Integrate the AWS SDK into the source code to connect with S3, DynamoDB, Cognito, and EventBridge.
- [ ] Write the actual `Dockerfile` for the API and update the ECS Task Definition (replacing the temporary `nginx` image with the real backend Docker image).

### Phase 2B: Frontend (Flutter) Integration
- [ ] Configure the Flutter application's endpoint URLs (in the `meomeo_flutter_app` directory) to point to the real API Gateway and S3 endpoints.
- [ ] Integrate the AWS Cognito SDK into the Flutter App to test the Registration / Login flows.

### Phase 3: CI/CD Automation
- [ ] Set up GitHub Actions workflows.
- [ ] Separate the `terraform/envs/dev` and `terraform/envs/prod` environments utilizing real AWS.
- [ ] Configure automated Docker Image Builds and pushes to Amazon ECR, followed by ECS Service updates upon new code pushes.
