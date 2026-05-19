# System Design - MeoMeo Cat Matching App

## 1. System Overview

MeoMeo is a mobile matchmaking app for cats. It allows cat owners to create multiple cat profiles, swipe to find suitable partners, create a match when both sides like each other, and then chat in a private room.

The proposed architecture uses AWS services, a Flutter mobile app, Amazon Cognito, API Gateway, Application Load Balancer, a self-hosted GraphQL backend, Amazon ECR, EC2 / ECS with Auto Scaling Group, DynamoDB, S3, CloudFront, EventBridge, SQS, SNS, APNs / FCM, and GitHub Actions for CI/CD.

## 2. High-level Architecture

## 2.1 Main components

| Layer | Component | Responsibility |
|---|---|---|
| Client | Flutter mobile app | iOS and Android application |
| Authentication | Amazon Cognito | Registration, login, JWT issuance |
| API entry | Amazon API Gateway | Public API entry point from the mobile app |
| Load balancing | Application Load Balancer | Routes requests to backend compute |
| Container registry | Amazon ECR | Stores backend Docker images |
| Compute | Amazon EC2 / ECS + Auto Scaling Group | Runs GraphQL API, worker, and Nginx reverse proxy |
| Business API | GraphQL API | Handles core business logic |
| Async events | Amazon EventBridge | Publishes domain events |
| Queue | Amazon SQS | Buffers background jobs |
| Notification | Amazon SNS | Sends push notifications through APNs / FCM |
| Database | Amazon DynamoDB | Stores users, cats, swipes, matches, chat metadata, premium status |
| Object storage | Amazon S3 | Stores cat avatars and albums |
| CDN | Amazon CloudFront | Delivers media from S3 |
| CI/CD | GitHub Actions | Builds, tests, pushes images, and deploys |

## 2.2 Deployment model

### Minimal MVP deployment

- One EC2 instance.
- Docker Compose runs:
  - GraphQL API.
  - Worker process.
  - Nginx reverse proxy.
- GitHub Actions builds the Docker image and pushes it to ECR.
- Deployment is performed by SSH into EC2.

### Final architecture aligned with the diagram

- API Gateway receives requests from the mobile app.
- API Gateway forwards requests to the Application Load Balancer.
- ALB routes requests to ECS services or EC2 instances in an Auto Scaling Group.
- EC2 instances run across multiple Availability Zones.
- Backend containers pull images from ECR.
- Worker consumes jobs from SQS.
- EventBridge receives domain events from the GraphQL API.
- S3 stores cat photos and CloudFront caches media.
- SNS sends notifications to APNs and FCM.

Recommendation: launch with the minimal MVP deployment, but design the codebase and Docker image so the system can later move to ECS + ASG without a rewrite.

## 3. Core Request Flows

## 3.1 Authentication flow

1. User registers or logs in from the Flutter app.
2. App calls Amazon Cognito.
3. Cognito validates credentials and returns a JWT token.
4. App stores the token securely.
5. Every API request includes `Authorization: Bearer <JWT>`.
6. API Gateway and backend receive the request.
7. Backend verifies the JWT against Cognito.
8. If valid, backend processes the request.
9. If invalid, backend returns `401 Unauthorized`.

## 3.2 API request flow

1. Flutter app calls the GraphQL endpoint.
2. Request goes through API Gateway.
3. API Gateway routes to ALB.
4. ALB forwards the request to a healthy backend container.
5. GraphQL API verifies the JWT.
6. GraphQL resolver executes business logic.
7. Backend reads from or writes to DynamoDB.
8. Backend publishes events to EventBridge when asynchronous processing is required.
9. Backend returns a GraphQL response to the app.

## 3.3 Image upload flow

1. App requests a pre-signed upload URL from GraphQL API.
2. Backend verifies user permission for the target cat profile.
3. Backend creates a short-lived S3 pre-signed URL.
4. App uploads the image directly to S3.
5. App calls backend to save image metadata.
6. Backend stores avatar or album URL in DynamoDB.
7. App displays media through CloudFront URL when CDN is enabled.

## 3.4 Swipe and match flow

1. User selects one owned cat profile as the active matching profile.
2. App sends a swipe mutation to GraphQL API.
3. Backend checks permission and validates that both cats are active.
4. Backend checks free or premium limits.
5. Backend stores the swipe record in DynamoDB.
6. If the swipe is right or Super Like, backend checks for reverse right swipe.
7. If reverse right swipe exists, backend creates a match using idempotent conditional write.
8. Backend creates or activates the related chat room.
9. Backend publishes `MatchCreated` event to EventBridge.
10. Worker processes the event and sends notifications through SNS.

## 3.5 Chat flow

1. User opens a chat room created from a match.
2. App sends a message mutation to GraphQL API.
3. Backend validates that the sender belongs to the matched conversation.
4. Backend stores the message in DynamoDB.
5. Backend updates chat room metadata such as `lastMessageAt`.
6. Backend publishes `MessageSent` event.
7. Worker sends push notification to the recipient.
8. Recipient opens the app and loads messages through GraphQL query.

## 3.6 Notification flow

1. Business event occurs, such as match, message, Super Like, Boost, or premium status update.
2. GraphQL API publishes event to EventBridge.
3. EventBridge routes event to SQS or worker target.
4. Worker reads the event.
5. Worker loads recipient device tokens.
6. Worker sends push notification through SNS.
7. SNS routes to APNs for iOS and FCM for Android.
8. Delivery result is logged.

## 4. Backend Services

## 4.1 GraphQL API

Recommended implementation options:

- NestJS GraphQL.
- Apollo Server.

Responsibilities:

- Single API entry point for the Flutter app.
- JWT verification.
- User and cat profile operations.
- Discovery feed queries.
- Swipe mutations.
- Match creation.
- Chat queries and mutations.
- Premium feature checks.
- S3 pre-signed URL generation.
- Event publishing to EventBridge.

## 4.2 Worker process

Responsibilities:

- Consume background jobs from SQS.
- Process match events.
- Process message events.
- Send push notifications.
- Update analytics counters if needed.
- Retry failed jobs.

The worker can run in the same EC2 instance for MVP and later move to a separate ECS service.

## 4.3 Nginx reverse proxy

Responsibilities:

- Reverse proxy traffic to the GraphQL API.
- Terminate or forward HTTP traffic depending on deployment setup.
- Provide a health check endpoint.
- Optionally apply request size limits.

## 5. Data Design

DynamoDB should be designed around access patterns rather than normalized relational modeling.

## 5.1 Main entities

- User.
- CatProfile.
- Swipe.
- Match.
- ChatRoom.
- Message.
- DeviceToken.
- PremiumSubscription.
- Boost.

## 5.2 Suggested DynamoDB tables

### Users table

**Primary key**

- `PK = USER#<userId>`
- `SK = PROFILE`

Stores user profile and premium status.

Example attributes:

- `userId`
- `cognitoSub`
- `email`
- `displayName`
- `premiumStatus`
- `premiumExpiresAt`
- `createdAt`
- `updatedAt`

### CatProfiles table

**Primary key**

- `PK = CAT#<catId>`
- `SK = PROFILE`

Suggested GSIs:

- `GSI1PK = OWNER#<ownerUserId>` to list cats by owner.
- `GSI2PK = STATUS#ACTIVE` for discovery candidates.
- Optional location-based GSI for future filtering.

Example attributes:

- `catId`
- `ownerUserId`
- `name`
- `gender`
- `breed`
- `age`
- `color`
- `furPattern`
- `legType`
- `eyeColorType`
- `description`
- `avatarUrl`
- `albumUrls`
- `preferences`
- `location`
- `status`
- `boostUntil`
- `createdAt`
- `updatedAt`

### Swipes table

**Primary key**

- `PK = FROM_CAT#<fromCatId>`
- `SK = TO_CAT#<toCatId>`

Suggested GSI:

- `GSI1PK = TO_CAT#<toCatId>` to support who-liked-me.

Example attributes:

- `fromCatId`
- `toCatId`
- `fromUserId`
- `toUserId`
- `type`: left / right / super_like
- `createdAt`

Idempotency:

- Use conditional write to prevent duplicate swipe records.

### Matches table

**Primary key**

- `PK = MATCH#<matchId>`
- `SK = META`

Suggested deterministic match ID:

- `matchId = sorted(catAId, catBId).join('#')`

Suggested GSIs:

- `GSI1PK = USER#<userId>` for user match list.
- `GSI2PK = CAT#<catId>` for cat-specific match list.

Example attributes:

- `matchId`
- `catAId`
- `catBId`
- `userAId`
- `userBId`
- `chatRoomId`
- `status`
- `createdAt`

### ChatRooms table

**Primary key**

- `PK = CHAT#<chatRoomId>`
- `SK = META`

Example attributes:

- `chatRoomId`
- `matchId`
- `participantUserIds`
- `lastMessageAt`
- `lastMessagePreview`
- `createdAt`

### Messages table

**Primary key**

- `PK = CHAT#<chatRoomId>`
- `SK = MSG#<createdAt>#<messageId>`

Example attributes:

- `messageId`
- `chatRoomId`
- `senderUserId`
- `content`
- `createdAt`
- `status`

### DeviceTokens table

**Primary key**

- `PK = USER#<userId>`
- `SK = DEVICE#<deviceId>`

Example attributes:

- `deviceId`
- `platform`: ios / android
- `token`
- `enabled`
- `createdAt`
- `updatedAt`

### UsageLimits table

**Primary key**

- `PK = USER#<userId>`
- `SK = DATE#<yyyy-mm-dd>`

Stores daily free-plan usage.

Example attributes:

- `rightSwipeCount`
- `superLikeCount`
- `boostUsedCount`
- `updatedAt`

## 6. GraphQL API Design

## 6.1 Example queries

```graphql
query MyCats {
  myCats {
    catId
    name
    breed
    avatarUrl
    status
  }
}
```

```graphql
query DiscoveryFeed($catId: ID!, $limit: Int) {
  discoveryFeed(catId: $catId, limit: $limit) {
    catId
    name
    breed
    age
    gender
    avatarUrl
    description
  }
}
```

```graphql
query MyMatches {
  myMatches {
    matchId
    chatRoomId
    catAId
    catBId
    createdAt
  }
}
```

```graphql
query ChatMessages($chatRoomId: ID!, $limit: Int, $cursor: String) {
  chatMessages(chatRoomId: $chatRoomId, limit: $limit, cursor: $cursor) {
    items {
      messageId
      senderUserId
      content
      createdAt
    }
    nextCursor
  }
}
```

## 6.2 Example mutations

```graphql
mutation CreateCatProfile($input: CreateCatProfileInput!) {
  createCatProfile(input: $input) {
    catId
    name
    status
  }
}
```

```graphql
mutation CreateUploadUrl($input: CreateUploadUrlInput!) {
  createUploadUrl(input: $input) {
    uploadUrl
    fileUrl
    expiresAt
  }
}
```

```graphql
mutation SwipeCat($input: SwipeCatInput!) {
  swipeCat(input: $input) {
    swipeId
    matched
    matchId
  }
}
```

```graphql
mutation SendMessage($input: SendMessageInput!) {
  sendMessage(input: $input) {
    messageId
    chatRoomId
    createdAt
  }
}
```

## 7. Event Design

## 7.1 EventBridge event types

| Event | Trigger | Consumer |
|---|---|---|
| `SwipeCreated` | User swipes left/right/super_like | Worker / analytics |
| `MatchCreated` | Mutual right swipe creates match | Worker notification |
| `MessageSent` | User sends message | Worker notification |
| `PhotoUploaded` | Cat photo metadata saved | Optional media worker |
| `PremiumActivated` | Premium status changes | Worker notification |
| `BoostStarted` | Boost starts | Discovery ranking / notification |

## 7.2 Example event payload

```json
{
  "eventType": "MatchCreated",
  "eventId": "evt_123",
  "occurredAt": "2026-05-18T10:00:00Z",
  "payload": {
    "matchId": "catA#catB",
    "catAId": "catA",
    "catBId": "catB",
    "userAId": "userA",
    "userBId": "userB",
    "chatRoomId": "chat_123"
  }
}
```

## 8. Discovery and Ranking

## 8.1 MVP ranking rules

The discovery feed can initially use rule-based ranking:

1. Exclude cats owned by the same user.
2. Exclude inactive cats.
3. Exclude cats already swiped by the current cat.
4. Prefer cats matching selected breed, gender, age, and location preferences.
5. Prioritize Super Liked profiles for the recipient.
6. Prioritize boosted cats while `boostUntil` is active.
7. Apply pagination.

## 8.2 Future ranking improvements

- Personalized scoring based on swipe behavior.
- Location distance ranking.
- Breed compatibility rules.
- Premium ranking controls.
- Abuse and spam filtering.

## 9. Free and Premium Logic

## 9.1 Free user restrictions

Backend must enforce:

- Daily right-swipe limit.
- No who-liked-me visibility.
- No Super Like.
- No undo for left swipe.
- Limited visibility controls.
- Limited discovery controls.

## 9.2 Premium user capabilities

Premium status unlocks:

- Unlimited right swipes.
- Who-liked-me list.
- Super Like.
- Undo left swipe.
- Visibility control.
- Discovery preference control.
- One free Boost per month.

## 9.3 Enforcement point

Premium checks must happen in the backend, not only in the mobile UI.

## 10. Security Design

## 10.1 Authentication

- Cognito manages registration and login.
- Cognito issues JWT tokens.
- Backend validates JWT signature, issuer, audience, and expiry.

## 10.2 Authorization

Backend must validate:

- User can only manage their own cat profiles.
- User can only request upload URLs for owned cats.
- User can only swipe using owned cats.
- User can only access matches that include them.
- User can only access chat rooms where they are a participant.
- User can only send messages in valid matched chat rooms.

## 10.3 S3 security

- Use private S3 bucket.
- Uploads must use short-lived pre-signed URLs.
- Restrict file type and file size.
- Use CloudFront for public media delivery when enabled.
- Avoid exposing write access to clients.

## 10.4 Secrets

- Store secrets in environment variables or AWS Systems Manager Parameter Store.
- Do not commit secrets to GitHub.
- Restrict IAM permissions by least privilege.

## 11. Reliability and Idempotency

## 11.1 Swipe idempotency

- One swipe pair should only have one current record.
- Conditional write prevents duplicate swipe records.
- Repeated requests should return existing result where appropriate.

## 11.2 Match idempotency

- Use deterministic match ID based on sorted cat IDs.
- Conditional write prevents duplicate matches.
- Match creation and chat room creation should be transaction-like.

## 11.3 Message reliability

- Store message before sending notification.
- Notification failure must not rollback message creation.
- Worker retries failed notification jobs.

## 11.4 Event processing

- Event handlers should be idempotent.
- SQS retry policy and dead-letter queue should be configured.
- Logs must include event ID for debugging.

## 12. CI/CD Design

## 12.1 GitHub Actions pipeline

Pipeline steps:

1. Developer pushes code to GitHub.
2. GitHub Actions runs lint and tests.
3. Build Docker image.
4. Push Docker image to Amazon ECR.
5. Deploy to EC2 / ECS.
6. Run health check.
7. Rollback or alert if deployment fails.

## 12.2 MVP deployment to EC2

- SSH into EC2.
- Pull latest Docker image from ECR.
- Restart Docker Compose services.
- Run health check endpoint.

## 12.3 Future deployment to ECS

- Register new task definition.
- Update ECS service.
- Use rolling deployment.
- Use ALB target group health checks.

## 13. Monitoring and Logging

## 13.1 Logs

Log the following:

- API request errors.
- Authentication failures.
- Swipe and match creation errors.
- Message send errors.
- EventBridge publish failures.
- Worker processing failures.
- SNS notification failures.

## 13.2 Metrics

Track:

- API latency.
- API error rate.
- Number of swipes.
- Number of matches.
- Number of messages.
- Notification success/failure rate.
- Image upload success/failure rate.
- DynamoDB throttling.
- EC2 CPU and memory usage.

## 13.3 Alerts

Recommended alerts:

- API 5xx error rate exceeds threshold.
- Backend health check fails.
- Worker queue depth is too high.
- DynamoDB throttling occurs.
- SNS notification failure rate spikes.
- EC2 CPU or memory usage is consistently high.

## 14. Scalability Plan

## 14.1 MVP stage

- Single EC2 instance.
- Docker Compose.
- DynamoDB on-demand or low provisioned capacity.
- S3 direct upload.
- Optional CloudFront.

## 14.2 Growth stage

- Move backend to ECS service.
- Use ALB target groups.
- Scale API containers horizontally.
- Run worker as separate ECS service.
- Add Auto Scaling Group or Fargate autoscaling.
- Add CloudFront for all media delivery.

## 14.3 Larger scale stage

- Separate read-heavy services if needed.
- Add caching layer for discovery feed if required.
- Improve DynamoDB partition design.
- Use analytics pipeline for behavior-based ranking.
- Add moderation pipeline.

## 15. Failure Scenarios

| Scenario | Expected behavior |
|---|---|
| Cognito unavailable | User cannot log in; existing valid sessions may continue until token expiry |
| DynamoDB write fails | API returns error; no swipe/match/message is confirmed |
| EventBridge publish fails | Core operation may still succeed, but event should be logged and retried if needed |
| S3 upload fails | App asks user to retry upload |
| SNS notification fails | Message/match remains valid; notification failure is logged |
| Worker down | Events remain in SQS and are processed after recovery |
| EC2 instance down | MVP may be unavailable; final ASG architecture routes to another healthy instance |

## 16. Technology Choices and Rationale

| Technology | Reason |
|---|---|
| Flutter | Single mobile codebase for iOS and Android |
| Amazon Cognito | AWS-native authentication, JWT support, suitable free tier for MVP |
| GraphQL | Flexible API for mobile app and nested profile data |
| EC2 | Simple, low-cost MVP deployment |
| Docker Compose | Easy local and single-server deployment |
| ECS / ASG | Future scalable container deployment |
| DynamoDB | AWS-native NoSQL database, scalable, good free tier |
| S3 | Low-cost and scalable media storage |
| CloudFront | Faster media delivery and caching |
| EventBridge | Decoupled event-driven architecture |
| SQS | Reliable queue for background jobs |
| SNS | Push notifications through APNs and FCM |
| GitHub Actions | Simple CI/CD from repository to AWS |

## 17. Open Technical Questions

- Should the MVP use only EC2, or include ECS from day one?
- Should API Gateway be used in MVP, or should the app call ALB directly?
- What exact free daily right-swipe limit should be configured?
- How long should pre-signed upload URLs remain valid?
- What maximum image size should be allowed?
- Should chat use polling in MVP or WebSocket for near real-time messaging?
- Should block/report be included in MVP for safety?
- Should payment be integrated immediately or managed manually for initial premium testing?

## 18. Recommended MVP Implementation Order

1. Set up AWS account, VPC, S3, DynamoDB, Cognito, and ECR.
2. Build Flutter authentication flow with Cognito.
3. Build GraphQL API with JWT verification.
4. Implement user and cat profile CRUD.
5. Implement S3 pre-signed upload.
6. Implement discovery feed.
7. Implement swipe logic.
8. Implement match creation with idempotency.
9. Implement chat rooms and messages.
10. Implement EventBridge, SQS, worker, and SNS notifications.
11. Implement free-plan usage limits.
12. Implement premium status checks, Super Like, undo, and Boost.
13. Add CI/CD with GitHub Actions.
14. Add logging, monitoring, and basic alerts.
