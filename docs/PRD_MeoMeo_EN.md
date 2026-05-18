# PRD - MeoMeo Cat Matching App

## 1. Product Overview

**Product name:** MeoMeo  
**Product type:** Mobile matchmaking app for cats  
**Platforms:** iOS and Android  
**Reference model:** Tinder-like matching, customized for cat profiles instead of human dating profiles.

MeoMeo helps cat owners create and manage multiple cat profiles under one user account, discover suitable cats, swipe right or left to express interest, create a match when both sides like each other, and then chat in a private room to discuss breeding needs or other relevant details.

## 2. Problem Statement

Cat owners often struggle to find suitable breeding partners for their cats because:

- Cat information is scattered across social groups and lacks standardization.
- It is difficult to filter by breed, fur color, physical traits, leg type, eye color, personality, or owner preferences.
- There is no clear mechanism to confirm mutual interest before starting a conversation.
- Existing discovery experiences are not fast, friendly, or visual enough.
- Cat photos and profiles are not managed centrally per cat.

## 3. Product Goals

### 3.1 Primary goals

- Allow one user account to manage multiple cat profiles.
- Allow owners to create detailed cat profiles with characteristics and photos.
- Let users discover other cats through a swipe-based experience.
- Create matches when both sides express interest.
- Enable private chat after a match is created.
- Support a freemium model with premium-only capabilities.

### 3.2 MVP goals

The MVP must support the following core flows:

1. User registration and login.
2. Create, update, and delete cat profiles.
3. Upload cat photos.
4. View recommended cat profiles.
5. Swipe right or left.
6. Create a match when two cats mutually like each other.
7. Create a private chat room after a match.
8. Send and receive basic messages.
9. Apply free-plan limitations.
10. Identify premium status and unlock premium capabilities.

## 4. Target Users

### 4.1 Primary user

**Cat owners who want to find a partner or breeding match for their cat.**

Needs:

- Create profiles for one or more cats.
- Find compatible cats based on preferred criteria.
- View photos, characteristics, and basic information about other cats.
- Communicate only with owners where there is mutual interest.

### 4.2 Secondary user

**Cat owners who want to explore the cat community or prepare for future matching.**

Needs:

- Browse cute cat profiles.
- Save or express interest in cats.
- Upgrade to premium when they want more control.

## 5. Product Scope

### 5.1 In scope for MVP

- Flutter mobile app for Android and iOS.
- Authentication using Amazon Cognito.
- User profile management.
- Multiple cat profiles under one user account.
- Cat avatar and album upload to Amazon S3 using pre-signed URLs.
- Discovery feed for recommended cats.
- Swipe right and swipe left.
- Mutual-like matching.
- Post-match chat.
- Free plan with daily swipe limits and feature restrictions.
- Premium status for unlocking advanced features.
- Push notifications for match, message, and premium-related events.
- Backend CI/CD using GitHub Actions.

### 5.2 Out of scope for MVP

- Complete in-app purchase implementation.
- Official breed certificate or document verification.
- Video calls.
- Livestreaming.
- Advanced AI recommendation.
- ML-based automatic moderation.
- Full web admin dashboard.
- TikTok-like social feed.
- Breeding appointment booking, deposits, or contracts.

These items can be considered for later phases.

## 6. Detailed Features

## 6.1 Registration and login

### Description

Users can register and log in to the app. Amazon Cognito manages accounts and issues JWT tokens.

### Main flow

1. User opens the app.
2. User registers or logs in.
3. The app receives a JWT token from Cognito.
4. The app uses the token when calling backend APIs.
5. The backend verifies the JWT before processing requests.

### Acceptance criteria

- User can register successfully with email and password.
- User can log in successfully and receive a valid token.
- API rejects requests without a token or with an invalid token.
- User can log out from the app.

## 6.2 Multiple cat profile management

### Description

A user account can create and manage multiple cat profiles. Each profile represents one cat.

### Minimum cat profile fields

- `catId`
- `ownerUserId`
- `name`
- `gender`
- `breed`
- `age`
- `color`
- `furPattern`
- `legType`: short legs / long legs
- `eyeColorType`: one-color eyes / two-color eyes
- `description`
- `avatarUrl`
- `albumUrls`
- `location`
- `status`: active / inactive
- `createdAt`
- `updatedAt`

### Partner preference fields

- Preferred breed.
- Preferred age range.
- Preferred gender.
- Preferred location.
- Preferred physical traits.
- Owner notes.

### Acceptance criteria

- One user can create multiple cat profiles.
- User can only update or delete cats owned by their account.
- Cat profile visibility can be turned on or off in discovery.
- Cat profile can have an avatar and multiple album photos.

## 6.3 Cat photo upload

### Description

The app uploads images directly to Amazon S3 using a pre-signed URL generated by the backend. The backend only stores image metadata and URLs.

### Main flow

1. App calls the GraphQL API to request a pre-signed URL.
2. Backend validates user permission.
3. Backend generates a pre-signed S3 URL.
4. App uploads the image directly to S3.
5. App calls the API again to update image metadata in the cat profile.
6. Images are served through CloudFront when CDN is enabled.

### Acceptance criteria

- User can only upload images for cats owned by their account.
- Upload must restrict allowed image file types.
- Upload must enforce file size limits.
- Image URL is saved in the cat profile.
- Uploaded image can be displayed in the app.

## 6.4 Discovery feed

### Description

User selects one of their cat profiles as the active matching profile. The app displays a list of suitable cats for swiping.

### MVP recommendation logic

Suggested profiles can be selected based on:

- Not owned by the same user.
- Active cat profile.
- Not already swiped by the current cat.
- Partial match with partner preferences.
- Premium or boosted cats may be prioritized.
- Location filtering if available.

### Acceptance criteria

- App shows one cat profile card at a time.
- Card includes photo, name, breed, age, gender, and short description.
- Previously swiped cats are not shown again, unless a premium undo feature is used.
- User does not see their own cats in discovery.

## 6.5 Swipe left and right

### Description

User swipes right to like a cat profile and swipes left to skip it.

### Swipe right flow

1. User selects their cat profile A.
2. User swipes right on cat profile B.
3. Backend records swipe history.
4. Backend checks whether cat B has already swiped right on cat A.
5. If yes, backend creates a match.
6. Backend publishes an event to EventBridge.
7. Worker handles match and notification events.

### Swipe left flow

1. User swipes left on cat profile B.
2. Backend records swipe history.
3. Cat B does not appear again in the standard feed.
4. Premium user can use undo to go back.

### Acceptance criteria

- Swipe history is stored by `fromCatId` and `toCatId`.
- Free users have a daily limit for right swipes.
- Mutual right swipe creates a match.
- Left swipe does not create a match.
- Duplicate swipe does not create duplicate records.

## 6.6 Matching

### Description

A match occurs when two cat profiles swipe right on each other.

### Match creation conditions

- Cat A swipes right on Cat B.
- Cat B already swiped right on Cat A, or the reverse.
- Both cat profiles are active.
- The two cats do not belong to the same user.
- No active match already exists between the two cats.

### Acceptance criteria

- Match is created only once for the same pair.
- Match stores both cat IDs and owner user IDs.
- A chat room is created or activated after match creation.
- Both owners receive a match notification.

## 6.7 Chat after match

### Description

After two cats match, their owners can chat in a private room.

### Main flow

1. Match is created.
2. Backend creates a chat room.
3. Both users can open the chat room.
4. User sends a message.
5. Backend saves message metadata.
6. Backend publishes a message event.
7. Worker triggers push notification to the recipient.

### MVP chat requirements

- Text messages only.
- Message list by chat room.
- Message timestamp.
- Sender information.
- Basic read status can be optional in MVP.

### Acceptance criteria

- Only matched users can access the chat room.
- User cannot send messages to unmatched users.
- Message is saved and can be retrieved.
- Recipient receives a notification when a message is sent.

## 6.8 Free plan

### Description

Free users can use the core matching experience, but with limitations.

### Free limitations

- Limited number of right swipes per day.
- Cannot see who liked their cat.
- Cannot send Super Like.
- Cannot undo a left swipe.
- Cannot control who sees their cat.
- Cannot fully control who they see in discovery.

### Acceptance criteria

- System tracks daily right-swipe usage.
- When limit is reached, user cannot continue swiping right until reset.
- Premium-only features are hidden or blocked for free users.
- User receives upgrade prompts when attempting premium features.

## 6.9 Premium plan

### Description

Premium users get unlimited swipes and advanced controls.

### Premium benefits

- Unlimited right swipes.
- Can see who liked their cat.
- Can send Super Like.
- Can undo accidental left swipe.
- Can control who can see their cat.
- Can control who they see in discovery by selecting cat types or preferences.
- Receives one free Boost per month, making their cat appear higher in other users' feeds.

### Acceptance criteria

- Premium status is stored and checked by backend.
- Premium users bypass free daily right-swipe limits.
- Premium users can access premium-only functions.
- Monthly free Boost is granted based on premium status.

## 6.10 Super Like

### Description

Super Like is a premium feature that prioritizes the sender's cat profile at the top of the recipient's discovery list.

### Acceptance criteria

- Only premium users can send Super Like.
- Super Like is recorded as a special swipe type.
- Recipient can identify that the cat was Super Liked.
- Super Liked profile receives priority in feed ranking.

## 6.11 Boost

### Description

Boost is a premium benefit that temporarily prioritizes a cat profile in the discovery feed of other users.

### Acceptance criteria

- Premium user receives one free Boost per month.
- Boost has a start time and end time.
- Boosted cats are prioritized in discovery ranking.
- Used Boost count is tracked.

## 6.12 Push notifications

### Description

The system sends push notifications for important events such as new matches and new messages.

### Notification types

- Match created.
- New message.
- Super Like received.
- Boost status update.
- Premium status update.

### Acceptance criteria

- User device token is saved.
- Notification event is published asynchronously.
- SNS sends notifications through APNs for iOS and FCM for Android.
- Notification failures are logged.

## 7. Monetization Model

MeoMeo uses a freemium model.

### Free

- Access to registration, cat profile creation, discovery, limited right swipes, matching, and chat.
- No access to premium discovery controls, who-liked-me, Super Like, undo, or monthly Boost.

### Premium

- Unlimited right swipes.
- Who-liked-me visibility.
- Super Like.
- Undo left swipe.
- Visibility control.
- Discovery preference control.
- One monthly Boost.

Payment implementation can be delayed until after MVP, but the backend should already support premium status checks.

## 8. Non-functional Requirements

## 8.1 Performance

- API response time for common requests should be under 500 ms under normal load.
- Discovery feed should load quickly for a smooth swipe experience.
- Image upload should happen directly to S3 instead of passing through backend.

## 8.2 Scalability

- Backend should be containerized.
- Architecture should support moving from one EC2 instance to ECS / Auto Scaling Group later.
- DynamoDB tables should be designed around access patterns.
- Asynchronous processing should be handled through EventBridge and SQS.

## 8.3 Security

- All API calls must require JWT authentication, except public health checks.
- Backend must verify Cognito JWT.
- Users can only access their own cats, matches, and chats.
- S3 uploads must use short-lived pre-signed URLs.
- Sensitive configuration must not be stored in source code.

## 8.4 Reliability

- Swipe, match, and message events should be idempotent.
- Duplicate events should not create duplicate matches or messages.
- Background jobs should be retryable.
- Notification failures should not block core user actions.

## 8.5 Cost

- MVP should optimize for low cost.
- Prefer AWS free tier where possible.
- Start with one EC2 instance and DynamoDB on-demand or low provisioned capacity.
- CloudFront can be added or enabled fully after early launch if needed.

## 9. Suggested Data Entities

## 9.1 User

| Field | Description |
|---|---|
| `userId` | Internal user ID |
| `cognitoSub` | Cognito user identifier |
| `email` | User email |
| `displayName` | User display name |
| `premiumStatus` | free / premium |
| `premiumExpiresAt` | Premium expiry time |
| `createdAt` | Creation timestamp |
| `updatedAt` | Update timestamp |

## 9.2 CatProfile

| Field | Description |
|---|---|
| `catId` | Cat profile ID |
| `ownerUserId` | Owner user ID |
| `name` | Cat name |
| `gender` | Cat gender |
| `breed` | Breed |
| `age` | Age |
| `color` | Fur color |
| `furPattern` | Fur pattern |
| `legType` | Short legs / long legs |
| `eyeColorType` | One-color / two-color eyes |
| `description` | Description |
| `avatarUrl` | Avatar URL |
| `albumUrls` | Album image URLs |
| `preferences` | Partner preferences |
| `location` | Location |
| `status` | active / inactive |
| `createdAt` | Creation timestamp |
| `updatedAt` | Update timestamp |

## 9.3 Swipe

| Field | Description |
|---|---|
| `swipeId` | Swipe ID |
| `fromCatId` | Cat that performed the swipe |
| `toCatId` | Target cat |
| `fromUserId` | Owner of source cat |
| `toUserId` | Owner of target cat |
| `type` | left / right / super_like |
| `createdAt` | Swipe timestamp |

## 9.4 Match

| Field | Description |
|---|---|
| `matchId` | Match ID |
| `catAId` | First cat |
| `catBId` | Second cat |
| `userAId` | First owner |
| `userBId` | Second owner |
| `chatRoomId` | Related chat room |
| `status` | active / blocked / deleted |
| `createdAt` | Match timestamp |

## 9.5 ChatRoom

| Field | Description |
|---|---|
| `chatRoomId` | Chat room ID |
| `matchId` | Related match |
| `participantUserIds` | Two participant user IDs |
| `lastMessageAt` | Last message time |
| `createdAt` | Creation timestamp |

## 9.6 Message

| Field | Description |
|---|---|
| `messageId` | Message ID |
| `chatRoomId` | Chat room ID |
| `senderUserId` | Sender user ID |
| `content` | Text message content |
| `createdAt` | Message timestamp |
| `status` | sent / delivered / read, optional for MVP |

## 10. Key User Stories

### User management

- As a user, I want to register and log in so that I can use the app securely.
- As a user, I want to manage my account so that my cat profiles are tied to me.

### Cat profile

- As a cat owner, I want to create multiple cat profiles so that each of my cats can have its own identity.
- As a cat owner, I want to upload photos so that other owners can see my cat clearly.
- As a cat owner, I want to set partner preferences so that I can find more suitable cats.

### Discovery and swipe

- As a cat owner, I want to browse cat cards so that I can find potential matches.
- As a cat owner, I want to swipe right to like a cat.
- As a cat owner, I want to swipe left to skip a cat.
- As a free user, I want to understand my daily right-swipe limit.

### Match and chat

- As a cat owner, I want a match to be created when both sides like each other.
- As a matched user, I want to chat privately with the other owner.
- As a user, I want to receive notifications for new matches and messages.

### Premium

- As a premium user, I want unlimited right swipes.
- As a premium user, I want to see who liked my cat.
- As a premium user, I want to send Super Likes.
- As a premium user, I want to undo an accidental left swipe.
- As a premium user, I want to control visibility and discovery preferences.
- As a premium user, I want one free Boost per month.

## 11. Success Metrics

### Activation

- Number of registered users.
- Percentage of users who create at least one cat profile.
- Percentage of cat profiles with avatar and album photos.

### Engagement

- Daily active users.
- Swipes per user per day.
- Right-swipe rate.
- Match rate.
- Chats started after match.
- Messages sent per match.

### Monetization

- Premium conversion rate.
- Premium retention rate.
- Super Like usage.
- Boost usage.

### Quality

- API error rate.
- Notification delivery success rate.
- Image upload success rate.
- Duplicate match rate.

## 12. Risks and Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Low profile quality | Poor matching experience | Require minimum profile fields and at least one photo |
| Duplicate swipe or match | Data inconsistency | Use idempotent keys and conditional writes |
| Abuse or spam messages | User dissatisfaction | Add block/report features in later phase |
| High media cost | Increased AWS bill | Use S3 lifecycle rules and CloudFront caching |
| Complex premium payment | Delayed MVP | Store premium status first; integrate payment later |
| Discovery quality too simple | Weak user retention | Start rule-based, improve ranking later |

## 13. Open Questions

- Which exact countries or cities should the MVP support first?
- What is the daily right-swipe limit for free users?
- How many Super Likes should premium users receive, if any limit is needed?
- How long does one Boost last?
- Should matching be between cats only, or should owner preferences also affect ranking?
- Should the app support block/report in MVP?
- Should chat support images in a later phase?
- How will premium payment be handled: Apple IAP, Google Play Billing, or manual admin control for MVP?

## 14. MVP Release Plan

### Phase 1 - Foundation

- Flutter app setup.
- Cognito authentication.
- GraphQL backend setup.
- DynamoDB base tables.
- S3 photo upload.

### Phase 2 - Core matching

- Cat profile CRUD.
- Discovery feed.
- Swipe left/right.
- Match creation.
- Chat room creation.

### Phase 3 - Messaging and notification

- Basic chat.
- Message persistence.
- EventBridge and SQS worker.
- SNS push notification.

### Phase 4 - Freemium

- Free swipe limit.
- Premium status check.
- Who-liked-me.
- Super Like.
- Undo.
- Boost.

### Phase 5 - Hardening

- Logging and monitoring.
- Error handling.
- Basic moderation preparation.
- Performance testing.
- CI/CD stabilization.
