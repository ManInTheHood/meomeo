# TinderMeoMeo (TIM) - Backlog

## Overview

TinderMeoMeo (TIM) là hệ thống backend/API phục vụ người dùng qua API Gateway, xác thực bằng Amazon Cognito, xử lý nghiệp vụ trên cụm EC2/ECS tối giản phía sau Application Load Balancer, lưu trữ dữ liệu ở DynamoDB và file ở S3/CloudFront. Phạm vi v1 tập trung vào authentication, API service core, file upload bằng presigned URL, notification async, CI/CD zero-downtime, và observability cơ bản.

**Target Release:** MVP v1 / H1 2026  
**Key Dependencies:**

- Amazon Cognito - xác thực, quản lý user pool, token validation.
- Amazon API Gateway - public API entrypoint, authorizer, routing tới ALB/backend.
- Application Load Balancer + EC2/ECS tối giản - phân phối traffic tới backend trong cấu hình cost-optimized, ưu tiên single-AZ cho dev/MVP thay vì 3 Availability Zones.
- Amazon ECS + ECR - đóng gói và triển khai Docker image cho backend service.
- Amazon DynamoDB - lưu metadata nghiệp vụ, trạng thái xử lý, mapping user/resource.
- Amazon S3 + CloudFront - lưu file/object và phục vụ nội dung qua CDN.
- Amazon EventBridge + SQS + SNS - xử lý job/event bất đồng bộ và push notification tới APNs/FCM.
- GitHub Actions - CI/CD pipeline build, test, push image, rolling update lên ECS.
- LocalStack - giả lập AWS services trong local/dev để test DynamoDB, S3, SQS, SNS/EventBridge trước khi deploy lên AWS thật.

**Reference Documents:**

- [TIM - TinderMeoMeo](https://docs.google.com/document/d/1385ch5abGyFHIt6cC-bmm1ANDygZXNWwCGIuP9kpUlg/edit?usp=sharing)
- [Architecture Diagram](https://drive.google.com/file/d/1NNzwBNKFLI1Y5yYd2tfSwYCTMdg_RuVH/view?usp=sharing)

**Relevant Repositories:**

- [ManInTheHood/meomeo](https://github.com/ManInTheHood/meomeo) - monorepo chính chứa backend, Terraform/LocalStack infrastructure, CI/CD config, context docs và Flutter app.
  - `backend/` - backend service, Docker/LocalStack, Terraform modules/envs.
  - `meomeo_flutter_app/` - Flutter mobile application.
  - `AI_CONTEXT/` - tài liệu context hỗ trợ development.
  - `.github/workflows/` - nên đặt GitHub Actions workflows tại đây nếu chưa có.

**Labels:**

- `epic:auth` - authentication, authorization, Cognito integration.
- `epic:api-core` - API Gateway, ALB routing, backend service foundation.
- `epic:storage` - DynamoDB, S3, CloudFront, presigned URL flow.
- `epic:async-notification` - EventBridge, SQS, SNS, APNs/FCM.
- `epic:infrastructure` - VPC, subnets, EC2 ASG, ECS, ECR, scaling.
- `epic:cicd-observability` - GitHub Actions, rolling deployment, logs, metrics, alerts.
- `release:mvp-v1` - scope bắt buộc cho MVP release.
- `repo:monorepo` - toàn bộ source code, infra và app nằm trong một repository duy nhất.
- `env:localstack` - ticket liên quan đến môi trường dev/local dùng LocalStack.
- `infra:cost-optimized` - hạ tầng MVP/dev ưu tiên giảm chi phí, không triển khai 3 HA/AZ.
- `phase:1` - ticket thuộc Phase 1: Core MVP.
- `phase:2` - ticket thuộc Phase 2: Enhanced Features.
- `phase:3` - ticket thuộc Phase 3: Optional / Fast-follow.

**Story Points Scale:**  
| Points | Complexity | Reference |
|---:|---|---|
| 1 | Trivial | config change, label, health endpoint nhỏ |
| 2 | Simple | single API endpoint hoặc IAM policy đơn giản |
| 3 | Moderate | integration nhỏ với AWS service |
| 5 | Complex | feature end-to-end có backend + infra + test |
| 8 | Large | workflow nhiều service, scale/security concern |
| 13 | Very Large | epic-level design hoặc migration rủi ro cao |

---

## Linear Management Practice

Backlog này dùng **Epic** làm cấp quản lý chính trong Linear. Vì vậy, trong Linear, **Milestone nên map với Epic**, không dùng Milestone để đại diện cho Cycle/Phase.

### Linear Field Mapping

| Backlog Field | Linear Field | Usage |
|---|---|---|
| Epic | Milestone | Mỗi Epic trong backlog tương ứng với một Linear Milestone. |
| Phase | Status + label | Phase không tạo Milestone riêng; dùng status để đưa ticket vào phase đang làm, và label `phase:1`, `phase:2`, `phase:3` để lọc. |
| Priority | Priority | P0/P1/P2 map sang priority tương ứng trong Linear. |
| Story Points | Estimate | Dùng estimate theo scale 1, 2, 3, 5, 8, 13. |
| Blocked By | Relations | Dùng relation `blocked by` / `blocking`. |
| Labels | Labels | Dùng labels như `epic:*`, `release:mvp-v1`, `repo:monorepo`, `env:localstack`, `infra:cost-optimized`, `phase:*`. |

### Milestone Strategy

Linear Milestones cần tạo theo Epic:

- Authentication & User Access
- API Core & Backend Service
- Infrastructure, Compute & Scaling
- Data Storage & File Delivery
- Async Processing & Notifications
- CI/CD, Release & Observability

Không tạo Milestone kiểu `Phase 1`, `Phase 2`, `Sprint 1`, `Cycle 1` cho backlog này. Phase được quản lý bằng ticket status và label.

### Phase / Cycle Management via Status

Mặc định, tất cả ticket mới nằm ở status `Backlog`.

Khi team bắt đầu một phase, move tất cả ticket thuộc phase đó sang `Planned`. Ví dụ khi bắt đầu Phase 1:

- Tất cả ticket có `Phase: 1` được chuyển từ `Backlog` sang `Planned`.
- Ticket Phase 2 và Phase 3 vẫn giữ ở `Backlog`.
- Khi ticket bắt đầu làm, chuyển từ `Planned` sang `In Progress`.
- Khi hoàn thành implementation, chuyển sang `In Review` hoặc `QA`.
- Khi xong hoàn toàn, chuyển sang `Done`.
- Nếu bị phụ thuộc hoặc chưa thể xử lý, chuyển sang `Blocked`.

### Recommended Linear Status Flow

| Status | Meaning |
|---|---|
| Backlog | Ticket chưa thuộc phase đang làm hoặc chưa được lên kế hoạch gần. |
| Planned | Ticket thuộc phase hiện tại và đã sẵn sàng để team pick up. |
| In Progress | Ticket đang được implement/design. |
| In Review | Ticket đang review code/design hoặc chờ QA. |
| Blocked | Ticket bị chặn bởi dependency, quyết định kỹ thuật, credential, infra hoặc external service. |
| Done | Ticket đã hoàn tất theo acceptance criteria. |

### Example

Khi bắt đầu Phase 1, các ticket như `TIM-AUTH-001`, `TIM-API-001`, `TIM-INFRA-005`, `TIM-STOR-001`, `TIM-CICD-001` sẽ được chuyển sang:

- Milestone: theo Epic tương ứng.
- Status: `Planned`.
- Label: `phase:1`.
- Priority: theo P0/P1/P2.
- Estimate: theo Story Points.
- Relations: set `Blocked By` nếu có.

Cách này giúp Linear dashboard ưu tiên hiển thị ticket của phase hiện tại, trong khi vẫn giữ Epic/Milestone rõ ràng theo backlog.

---

# Epic 1: Authentication & User Access

**Epic Description:** Thiết lập luồng đăng ký/đăng nhập, xác thực token, phân quyền truy cập API, và liên kết user identity với dữ liệu trong hệ thống.  
**Label:** `epic:auth`

---

## TIM-AUTH-001: Configure Cognito User Pool and App Client

**Type:** Task | **Priority:** P0 | **Phase:** 1 | **Story Points:** 5<br>
**Labels:** `epic:auth`, `release:mvp-v1`, `phase:1`<br>
**Blocked By:** -

### Description

Thiết lập Amazon Cognito để hỗ trợ đăng ký, đăng nhập, refresh token, password policy, và app client cho frontend/mobile app.

### Acceptance Criteria

- [ ] User Pool được tạo với password policy và required attributes phù hợp.
- [ ] App Client hỗ trợ OAuth/token flow theo nhu cầu client.
- [ ] Có cấu hình callback/logout URL nếu dùng hosted UI.
- [ ] Có tài liệu environment variables cần dùng cho client và backend.

### Technical Notes

- Ưu tiên IaC để có thể tái tạo môi trường dev/staging/prod.
- Cần quyết định username là email hay custom username.
- Cần chuẩn hóa token claims dùng cho authorization.

### Resources

- [TIM - TinderMeoMeo](https://docs.google.com/document/d/1385ch5abGyFHIt6cC-bmm1ANDygZXNWwCGIuP9kpUlg/edit?usp=sharing)
- [Architecture Diagram](https://drive.google.com/file/d/1NNzwBNKFLI1Y5yYd2tfSwYCTMdg_RuVH/view?usp=sharing)

---

## TIM-AUTH-002: Integrate API Gateway Cognito Authorizer

**Type:** Task | **Priority:** P0 | **Phase:** 1 | **Story Points:** 5<br>
**Labels:** `epic:auth`, `release:mvp-v1`, `phase:1`<br>
**Blocked By:** TIM-AUTH-001

### Description

Bảo vệ các API cần đăng nhập bằng Cognito authorizer tại API Gateway, chỉ cho request có token hợp lệ đi tiếp vào backend.

### Acceptance Criteria

- [ ] API Gateway reject request không có token hoặc token không hợp lệ.
- [ ] Public routes và protected routes được phân tách rõ.
- [ ] Backend nhận được identity/claims cần thiết từ request context/header.
- [ ] Có test cho các case: missing token, expired token, invalid token, valid token.

### Technical Notes

- Cần thống nhất mapping claims từ API Gateway xuống backend.
- Không hard-code user pool ID/client ID trong source code.

---

## TIM-AUTH-003: Implement Backend User Context Middleware

**Type:** Task | **Priority:** P0 | **Phase:** 1 | **Story Points:** 3<br>
**Labels:** `epic:auth`, `release:mvp-v1`, `phase:1`<br>
**Blocked By:** TIM-AUTH-002

### Description

Xây middleware backend để parse user identity từ request đã xác thực và cung cấp user context thống nhất cho các API nghiệp vụ.

### Acceptance Criteria

- [ ] Middleware expose userId, email, roles/scopes nếu có.
- [ ] API protected không tự parse token lặp lại ở từng handler.
- [ ] Có unit test cho middleware.
- [ ] Error response nhất quán khi thiếu identity context.

### Technical Notes

- Nếu API Gateway đã validate token, backend chỉ cần tin vào context/header đã được kiểm soát.
- Cần tránh log raw token hoặc thông tin nhạy cảm.

---

# Epic 2: API Core & Backend Service

**Epic Description:** Xây nền backend service chạy phía sau ALB, nhận traffic từ API Gateway, cung cấp API core, health check, versioning và contract cơ bản.  
**Label:** `epic:api-core`

---

## TIM-API-001: Define API Contract for MVP

**Type:** Design | **Priority:** P0 | **Phase:** 1 | **Story Points:** 5<br>
**Labels:** `epic:api-core`, `release:mvp-v1`, `phase:1`<br>
**Blocked By:** -

### Description

Chốt API contract MVP dựa trên TIM: endpoint, request/response schema, error model, auth requirement, pagination, và versioning.

### Acceptance Criteria

- [ ] Có danh sách endpoint MVP, phân loại public/protected.
- [ ] Có schema request/response cho từng endpoint.
- [ ] Có chuẩn error response chung.
- [ ] Có version prefix hoặc versioning strategy.
- [ ] API contract được review trước khi implement backend.

### Technical Notes

- Nên dùng OpenAPI/Swagger làm source of truth.
- Cần đồng bộ với frontend/mobile nếu có.

### Resources

- [TIM - TinderMeoMeo](https://docs.google.com/document/d/1385ch5abGyFHIt6cC-bmm1ANDygZXNWwCGIuP9kpUlg/edit?usp=sharing)

---

## TIM-API-002: Implement Backend Service Skeleton

**Type:** Task | **Priority:** P0 | **Phase:** 1 | **Story Points:** 5<br>
**Labels:** `epic:api-core`, `release:mvp-v1`, `phase:1`<br>
**Blocked By:** TIM-API-001

### Description

Tạo backend service skeleton có routing, config management, health endpoint, structured logging, và Dockerfile để deploy lên ECS/EC2.

### Acceptance Criteria

- [ ] Service có `/health` hoặc `/status` endpoint cho ALB health check.
- [ ] Config đọc từ environment variables/secrets.
- [ ] Docker image build được local và trong CI.
- [ ] Có logging JSON hoặc structured log cơ bản.
- [ ] Có unit test smoke test cho app boot.

### Technical Notes

- Health endpoint không nên phụ thuộc vào toàn bộ external services nếu dùng cho ALB.
- Có thể tách liveness/readiness nếu cần.

---

## TIM-API-003: Route API Gateway to ALB/Backend

**Type:** Task | **Priority:** P0 | **Phase:** 1 | **Story Points:** 5<br>
**Labels:** `epic:api-core`, `release:mvp-v1`, `phase:1`<br>
**Blocked By:** TIM-API-002, TIM-INFRA-003

### Description

Cấu hình API Gateway route request tới Application Load Balancer, đảm bảo request path, method, headers và response được truyền đúng.

### Acceptance Criteria

- [ ] API Gateway forward được request tới backend qua ALB.
- [ ] Backend nhận đúng path/method/header cần thiết.
- [ ] Error từ backend được trả về client đúng format.
- [ ] Có smoke test từ public API URL tới backend health endpoint.

### Technical Notes

- Cần cân nhắc private integration/VPC link nếu ALB private.
- Nếu ALB public, cần security group/WAF hạn chế nguồn gọi nếu phù hợp.

---

## TIM-API-004: Implement Standard Error Handling and Request Validation

**Type:** Task | **Priority:** P1 | **Phase:** 1 | **Story Points:** 3<br>
**Labels:** `epic:api-core`, `release:mvp-v1`, `phase:1`<br>
**Blocked By:** TIM-API-002

### Description

Chuẩn hóa validation và error handling để tất cả API trả response nhất quán, dễ debug và dễ consume bởi client.

### Acceptance Criteria

- [ ] Validation error trả về field-level message.
- [ ] Server error không expose stack trace ra client.
- [ ] Có correlation/request ID trong log và response nếu phù hợp.
- [ ] Có test cho validation failure và unexpected error.

### Technical Notes

- Nên map lỗi thành nhóm 400/401/403/404/409/500.
- Log chi tiết ở server, response cho client giữ gọn.

---

# Epic 3: Infrastructure, Compute & Scaling

**Epic Description:** Provision network, compute, container registry, ECS/EC2 service, load balancer, scaling tối giản và security baseline theo hướng cost-optimized cho MVP/dev.  
**Label:** `epic:infrastructure`

---

## TIM-INFRA-001: Design Cost-Optimized VPC, Subnets, Security Groups

**Type:** Design | **Priority:** P0 | **Phase:** 1 | **Story Points:** 5<br>
**Labels:** `epic:infrastructure`, `release:mvp-v1`, `phase:1`<br>
**Blocked By:** -

### Description

Thiết kế VPC cost-optimized cho MVP/dev, ưu tiên single-AZ hoặc tối đa 2-AZ tùy nhu cầu, với subnet, route table, security group và network boundary cho ALB/backend.

### Acceptance Criteria

- [ ] Có VPC layout cost-optimized, mặc định single-AZ cho dev/MVP; không setup 3 Availability Zones.
- [ ] Có subnet plan, route table, internet/NAT decision theo hướng giảm chi phí.
- [ ] Security group rule chỉ mở port cần thiết.
- [ ] Có diagram/README mô tả traffic flow.

### Technical Notes

- Diagram ban đầu thể hiện 3 Availability Zones, nhưng MVP/dev sẽ không triển khai 3 HA để tránh chi phí cao.
- Nếu backend cần gọi AWS services, cân nhắc tránh NAT Gateway trong dev vì tốn chi phí; dùng public subnet có security group chặt, VPC endpoints chọn lọc, hoặc LocalStack khi local.

### Resources

- [Architecture Diagram](https://drive.google.com/file/d/1NNzwBNKFLI1Y5yYd2tfSwYCTMdg_RuVH/view?usp=sharing)

---

## TIM-INFRA-002: Provision ECR Repository and Image Policy

**Type:** Task | **Priority:** P0 | **Phase:** 1 | **Story Points:** 2<br>
**Labels:** `epic:infrastructure`, `release:mvp-v1`, `phase:1`<br>
**Blocked By:** -

### Description

Tạo Amazon ECR repository cho backend Docker image, kèm lifecycle policy và quyền push/pull cho CI/CD và ECS.

### Acceptance Criteria

- [ ] ECR repo được tạo cho backend service.
- [ ] CI có quyền push image.
- [ ] ECS/EC2 task/service có quyền pull image.
- [ ] Lifecycle policy giữ số version hợp lý, tránh tăng storage không kiểm soát.

### Technical Notes

- Image tag nên gồm commit SHA và optional release tag.
- Không dùng `latest` làm duy nhất source of truth cho deploy.

---

## TIM-INFRA-003: Provision Cost-Optimized ALB, ECS Service and EC2 Capacity

**Type:** Task | **Priority:** P0 | **Phase:** 1 | **Story Points:** 8<br>
**Labels:** `epic:infrastructure`, `release:mvp-v1`, `infra:cost-optimized`, `phase:1`<br>
**Blocked By:** TIM-INFRA-001, TIM-INFRA-002, TIM-API-002

### Description

Triển khai backend container chạy trên ECS/EC2 phía sau Application Load Balancer với cấu hình tối giản cho dev/MVP, ưu tiên 1 instance/task baseline và chỉ scale khi thật sự cần.

### Acceptance Criteria

- [ ] ALB target group health check pass với backend service.
- [ ] ECS service chạy container từ ECR image.
- [ ] Capacity mặc định dùng single-AZ/single instance hoặc desired count thấp để giảm chi phí.
- [ ] Rolling replacement có strategy phù hợp với capacity thấp, chấp nhận maintenance window ngắn nếu cần cho dev/MVP.
- [ ] Security group cho phép ALB gọi backend port cần thiết.

### Technical Notes

- Diagram ban đầu thể hiện ECS/EC2 trải qua 3 AZ, nhưng backlog đã điều chỉnh sang cost-optimized single-AZ cho MVP/dev.
- Cần xác định launch template instance type nhỏ, desired/min/max capacity thấp, ví dụ desired=1 cho dev/MVP.
- Cần quyết định ECS cluster capacity provider nếu dùng ECS on EC2; cân nhắc Fargate nếu vận hành đơn giản hơn nhưng phải so sánh chi phí.

---

## TIM-INFRA-004: Configure Auto Scaling Policies

**Type:** Task | **Priority:** P1 | **Phase:** 2 | **Story Points:** 5<br>
**Labels:** `epic:infrastructure`, `release:mvp-v1`, `phase:2`<br>
**Blocked By:** TIM-INFRA-003

### Description

Thiết lập scaling policy tối giản dựa trên CPU/memory/request count, nhưng mặc định không bật 3 HA hoặc capacity cao trong dev/MVP để kiểm soát chi phí.

### Acceptance Criteria

- [ ] Có target tracking hoặc step scaling policy.
- [ ] Có cooldown phù hợp để tránh scale flapping.
- [ ] Có dashboard theo dõi desired/running capacity.
- [ ] Có test scale-out/scale-in ở staging hoặc môi trường AWS dev khi cần.

### Technical Notes

- Nên bắt đầu với min=1/desired=1 cho dev/MVP, chỉ tăng min/desired khi có traffic thật hoặc demo cần ổn định.
- Nếu traffic chủ yếu qua ALB, cân nhắc RequestCountPerTarget.

---

## TIM-INFRA-005: Setup LocalStack Dev Environment

**Type:** Task | **Priority:** P0 | **Phase:** 1 | **Story Points:** 5<br>
**Labels:** `epic:infrastructure`, `release:mvp-v1`, `env:localstack`, `repo:monorepo`, `phase:1`<br>
**Blocked By:** TIM-INFRA-001, TIM-INFRA-002

### Description

Thiết lập môi trường dev/local dùng LocalStack để giả lập các AWS services cần cho MVP, giúp backend có thể test DynamoDB, S3, SQS, SNS/EventBridge bằng Docker Compose và Terraform local trước khi deploy lên AWS dev/staging thật.

### Acceptance Criteria

- [ ] Có `docker-compose.dev.yml` hoặc compose profile chạy được LocalStack local.
- [ ] Terraform `envs/local` trỏ vào LocalStack endpoint `http://localhost:4566`.
- [ ] Có script/Makefile cho các lệnh `local-up`, `local-apply`, `local-down`, `local-reset`.
- [ ] LocalStack provision được các resource dev tối thiểu: DynamoDB table, S3 bucket, SQS queue, SNS topic/EventBridge rule nếu cần.
- [ ] Backend đọc được local AWS endpoint khi `APP_ENV=local` hoặc config tương đương.
- [ ] README hướng dẫn flow local: start LocalStack -> apply Terraform local -> run backend -> run integration tests.
- [ ] Không dùng LocalStack thay thế AWS dev/staging cho API Gateway, Cognito, CloudFront, ECS/ALB/ASG hoặc push notification thật.

### Technical Notes

- LocalStack chỉ áp dụng cho local/dev, không apply vào staging/prod.
- Ticket này nên làm trước hoặc song song với DynamoDB/S3/SQS implementation.
- Nên giữ folder rõ ràng: `backend/infra/envs/local`, `backend/infra/envs/dev`, `backend/infra/envs/prod`.
- Với AWS services không giả lập đủ chính xác, dùng LocalStack cho fast feedback rồi verify lại trên AWS dev/staging.

---

# Epic 4: Data Storage & File Delivery

**Epic Description:** Thiết kế và triển khai lưu trữ metadata trong DynamoDB, file upload/download qua S3 presigned URL, và phân phối file qua CloudFront.  
**Label:** `epic:storage`

---

## TIM-STOR-001: Design DynamoDB Data Model

**Type:** Design | **Priority:** P0 | **Phase:** 1 | **Story Points:** 5<br>
**Labels:** `epic:storage`, `release:mvp-v1`, `phase:1`<br>
**Blocked By:** TIM-API-001

### Description

Thiết kế data model DynamoDB cho các entity MVP, bao gồm partition key, sort key, secondary indexes, access pattern và TTL nếu cần.

### Acceptance Criteria

- [ ] Có danh sách entity và access pattern chính.
- [ ] Có schema key cho từng table/index.
- [ ] Có strategy cho uniqueness, pagination, status query.
- [ ] Có capacity/billing mode đề xuất.
- [ ] Có migration/seed strategy cơ bản.

### Technical Notes

- DynamoDB nên được thiết kế từ access pattern, không từ ERD truyền thống.
- Cần xác nhận các nghiệp vụ chính từ TIM trước khi final.

---

## TIM-STOR-002: Implement DynamoDB Repository Layer

**Type:** Task | **Priority:** P0 | **Phase:** 1 | **Story Points:** 5<br>
**Labels:** `epic:storage`, `release:mvp-v1`, `phase:1`<br>
**Blocked By:** TIM-STOR-001, TIM-API-002, TIM-INFRA-005

### Description

Xây repository/data access layer cho backend để đọc/ghi DynamoDB theo data model đã chốt.

### Acceptance Criteria

- [ ] Có repository abstraction cho các entity MVP.
- [ ] Có error mapping cho conditional check, not found, throttling.
- [ ] Có unit/integration test với local/staging DynamoDB.
- [ ] Không leak AWS SDK response thô ra service layer.

### Technical Notes

- Dùng conditional writes cho create/update cần idempotency hoặc concurrency control.
- Cần log request ID, không log payload nhạy cảm.

---

## TIM-STOR-003: Implement S3 Presigned URL Upload Flow

**Type:** Task | **Priority:** P0 | **Phase:** 1 | **Story Points:** 5<br>
**Labels:** `epic:storage`, `release:mvp-v1`, `phase:1`<br>
**Blocked By:** TIM-AUTH-003, TIM-STOR-002, TIM-INFRA-005

### Description

Cung cấp API để backend tạo presigned URL cho client upload file trực tiếp lên S3, đồng thời lưu metadata file vào DynamoDB.

### Acceptance Criteria

- [ ] Protected API tạo presigned upload URL cho user hợp lệ.
- [ ] File key có prefix theo user/resource để tránh collision.
- [ ] URL có thời hạn ngắn và giới hạn content type/size nếu có thể.
- [ ] Metadata file được lưu với trạng thái pending/uploaded theo flow đã chọn.
- [ ] Có test cho user không được phép tạo URL cho resource của người khác.

### Technical Notes

- Diagram thể hiện backend tạo presigned URL tới S3.
- Cần cân nhắc callback/verification sau upload nếu cần chắc chắn file đã tồn tại.
- Không proxy file upload qua backend nếu không cần.

---

## TIM-STOR-004: Configure CloudFront for File Delivery

**Type:** Task | **Priority:** P1 | **Phase:** 2 | **Story Points:** 5<br>
**Labels:** `epic:storage`, `release:mvp-v1`, `phase:2`<br>
**Blocked By:** TIM-STOR-003

### Description

Cấu hình CloudFront trước S3 để phân phối file nhanh và kiểm soát truy cập download theo yêu cầu sản phẩm.

### Acceptance Criteria

- [ ] CloudFront distribution trỏ tới S3 origin.
- [ ] S3 bucket không public trực tiếp nếu file cần bảo vệ.
- [ ] Có cache behavior phù hợp cho object/file.
- [ ] Có strategy signed URL/signed cookie nếu file private.
- [ ] Download URL được backend trả theo quyền truy cập.

### Technical Notes

- Nếu MVP chưa cần CDN, có thể dùng S3 presigned download trước rồi fast-follow CloudFront.
- Cần xác nhận yêu cầu file public/private từ TIM.

---

# Epic 5: Async Processing & Notifications

**Epic Description:** Thiết lập event-driven flow bằng EventBridge, SQS, SNS để xử lý tác vụ nền và gửi push notification tới iOS/Android.  
**Label:** `epic:async-notification`

---

## TIM-ASYNC-001: Define Event and Queue Contract

**Type:** Design | **Priority:** P1 | **Phase:** 1 | **Story Points:** 3<br>
**Labels:** `epic:async-notification`, `release:mvp-v1`, `phase:1`<br>
**Blocked By:** TIM-API-001

### Description

Định nghĩa event schema, queue message contract, retry policy và dead-letter strategy cho các workflow async trong MVP.

### Acceptance Criteria

- [ ] Có danh sách event type MVP.
- [ ] Có schema message cho từng event type.
- [ ] Có retry/DLQ policy đề xuất.
- [ ] Có idempotency key hoặc event ID strategy.
- [ ] Có tài liệu consumer behavior.

### Technical Notes

- Diagram có EventBridge -> SQS -> backend/worker flow và SNS -> APNs/FCM flow.
- Cần xác định event nào synchronous, event nào async.

---

## TIM-ASYNC-002: Implement EventBridge Publisher

**Type:** Task | **Priority:** P1 | **Phase:** 2 | **Story Points:** 3<br>
**Labels:** `epic:async-notification`, `release:mvp-v1`, `phase:2`<br>
**Blocked By:** TIM-ASYNC-001, TIM-API-002

### Description

Backend publish domain events lên EventBridge khi các hành động nghiệp vụ quan trọng xảy ra.

### Acceptance Criteria

- [ ] Backend publish được event với schema đã định nghĩa.
- [ ] Event có correlation ID/user/resource reference.
- [ ] Publish failure được log và xử lý theo policy.
- [ ] Có test cho event serialization.

### Technical Notes

- Không nên publish payload quá lớn; chỉ gửi reference nếu cần.
- Cần thống nhất event source/detail-type naming.

---

## TIM-ASYNC-003: Implement SQS Consumer Worker

**Type:** Task | **Priority:** P1 | **Phase:** 2 | **Story Points:** 5<br>
**Labels:** `epic:async-notification`, `release:mvp-v1`, `phase:2`<br>
**Blocked By:** TIM-ASYNC-001, TIM-INFRA-005

### Description

Xây worker/consumer đọc message từ SQS, xử lý idempotent và cập nhật trạng thái vào DynamoDB khi cần.

### Acceptance Criteria

- [ ] Worker poll/consume SQS message ổn định.
- [ ] Message xử lý thành công được delete khỏi queue.
- [ ] Failure được retry theo visibility timeout/redrive policy.
- [ ] Có DLQ cho message lỗi quá số lần retry.
- [ ] Consumer xử lý idempotent khi nhận duplicate message.

### Technical Notes

- Có thể deploy worker cùng ECS cluster hoặc tách service riêng.
- Cần dashboard cho queue depth, age of oldest message, DLQ count.

---

## TIM-ASYNC-004: Implement SNS Push Notification Flow

**Type:** Task | **Priority:** P1 | **Phase:** 2 | **Story Points:** 5<br>
**Labels:** `epic:async-notification`, `release:mvp-v1`, `phase:2`<br>
**Blocked By:** TIM-AUTH-003, TIM-STOR-002, TIM-INFRA-005

### Description

Tích hợp Amazon SNS để gửi push notification tới APNs iOS và FCM Android theo device token của user.

### Acceptance Criteria

- [ ] Backend lưu và cập nhật device token theo user.
- [ ] SNS platform application được cấu hình cho APNs và FCM.
- [ ] API cho phép register/unregister device token.
- [ ] Có flow gửi notification thử nghiệm tới iOS/Android.
- [ ] Invalid token được xử lý và cleanup.

### Technical Notes

- Diagram thể hiện SNS route tới APNs/FCM.
- Cần bảo vệ device token, tránh log token đầy đủ.
- Cần xác nhận notification type nào thuộc MVP.

---

# Epic 6: CI/CD, Release & Observability

**Epic Description:** Tự động hóa build/test/deploy qua GitHub Actions, rolling update zero downtime, cùng log/metric/alert cơ bản để vận hành MVP.  
**Label:** `epic:cicd-observability`

---

## TIM-CICD-001: Build and Test Pipeline with GitHub Actions for Monorepo

**Type:** Task | **Priority:** P0 | **Phase:** 1 | **Story Points:** 3<br>
**Labels:** `epic:cicd-observability`, `release:mvp-v1`, `phase:1`<br>
**Blocked By:** TIM-API-002

### Description

Thiết lập GitHub Actions workflow trong cùng repository `ManInTheHood/meomeo`, chạy lint/test/build theo từng path backend/mobile để phù hợp mô hình monorepo.

### Acceptance Criteria

- [ ] Workflow chạy lint/test trên pull request.
- [ ] Workflow dùng path filter cho `backend/` và `meomeo_flutter_app/` để tránh chạy job không cần thiết.
- [ ] Build Docker image thành công trong CI.
- [ ] CI fail nếu test hoặc build lỗi.
- [ ] Có cache dependency nếu phù hợp để giảm thời gian build.

### Technical Notes

- Diagram CI/CD gồm push code -> build & test -> build Docker image.
- Không cần tạo thêm repo chỉ để tách backend/mobile/infra; dùng folder boundary và branch protection là đủ cho MVP.
- Không để secret plaintext trong workflow file.

---

## TIM-CICD-002: Push Docker Image to ECR

**Type:** Task | **Priority:** P0 | **Phase:** 1 | **Story Points:** 3<br>
**Labels:** `epic:cicd-observability`, `release:mvp-v1`, `phase:1`<br>
**Blocked By:** TIM-CICD-001, TIM-INFRA-002

### Description

Mở rộng pipeline để authenticate AWS, tag Docker image, và push image lên Amazon ECR.

### Acceptance Criteria

- [ ] CI login ECR bằng role/secret an toàn.
- [ ] Image được tag bằng commit SHA.
- [ ] Image được push thành công lên ECR.
- [ ] Có artifact/link để trace commit -> image tag.

### Technical Notes

- Ưu tiên OIDC role cho GitHub Actions thay vì long-lived AWS keys.
- Cần phân quyền IAM tối thiểu cho push image.

---

## TIM-CICD-003: Rolling Update Deployment to ECS

**Type:** Task | **Priority:** P0 | **Phase:** 1 | **Story Points:** 5<br>
**Labels:** `epic:cicd-observability`, `release:mvp-v1`, `phase:1`<br>
**Blocked By:** TIM-CICD-002, TIM-INFRA-003

### Description

Tự động deploy image mới lên ECS bằng rolling update, đảm bảo zero downtime theo architecture pipeline.

### Acceptance Criteria

- [ ] Pipeline update ECS service/task definition bằng image tag mới.
- [ ] Deployment giữ minimum healthy percent phù hợp.
- [ ] Pipeline fail nếu service không stabilize.
- [ ] Có rollback/manual redeploy instruction.
- [ ] Không có downtime trong smoke test deployment.

### Technical Notes

- Diagram ghi rõ rolling update zero downtime từ ECR sang ECS.
- Cần health check ổn định trước khi bật deploy tự động.

---

## TIM-CICD-004: Add Centralized Logging and Metrics

**Type:** Task | **Priority:** P1 | **Phase:** 2 | **Story Points:** 5<br>
**Labels:** `epic:cicd-observability`, `release:mvp-v1`, `phase:2`<br>
**Blocked By:** TIM-INFRA-003, TIM-API-002

### Description

Thiết lập log, metric và dashboard cơ bản cho API, ALB, ECS/EC2, DynamoDB, SQS/SNS để đội có thể vận hành MVP.

### Acceptance Criteria

- [ ] Backend logs được gửi tới CloudWatch hoặc logging backend đã chọn.
- [ ] Dashboard có request count, latency, error rate, CPU/memory, queue depth.
- [ ] Có alert cho 5xx spike, service unhealthy, queue backlog, DLQ message.
- [ ] Có runbook ngắn cho incident cơ bản.

### Technical Notes

- Nên thêm correlation/request ID từ API Gateway/backend.
- Phase 1 có thể chỉ cần log + metric chính, Phase 2 bổ sung alert đầy đủ.

---

## TIM-CICD-005: Security Baseline and Secret Management

**Type:** Task | **Priority:** P1 | **Phase:** 2 | **Story Points:** 5<br>
**Labels:** `epic:cicd-observability`, `release:mvp-v1`, `phase:2`<br>
**Blocked By:** TIM-INFRA-003

### Description

Thiết lập baseline bảo mật cho secrets, IAM, network và logging để tránh rủi ro phổ biến trước khi release.

### Acceptance Criteria

- [ ] Secrets không nằm trong source code hoặc image.
- [ ] IAM roles theo principle of least privilege.
- [ ] S3 bucket policy không public ngoài ý muốn.
- [ ] Security groups chỉ mở inbound/outbound cần thiết.
- [ ] Có audit checklist trước release.

### Technical Notes

- Cân nhắc AWS Secrets Manager/SSM Parameter Store.
- Cần review quyền CI/CD, ECS task role, S3, DynamoDB, SNS/SQS.

---

## TIM-CICD-006: Organize Monorepo Boundaries and Developer Commands

**Type:** Task | **Priority:** P1 | **Phase:** 1 | **Story Points:** 3<br>
**Labels:** `epic:cicd-observability`, `release:mvp-v1`, `repo:monorepo`, `phase:1`<br>
**Blocked By:** -

### Description

Chuẩn hóa cấu trúc repository duy nhất để backend, mobile app, Terraform/LocalStack và tài liệu có boundary rõ ràng, dễ chạy local và dễ mở rộng sau này.

### Acceptance Criteria

- [ ] README root mô tả nhanh cấu trúc repo và cách chạy từng phần.
- [ ] `backend/README.md` hoặc root README có lệnh local-up, terraform init/apply, test backend.
- [ ] `meomeo_flutter_app/README.md` có lệnh chạy app, build, test.
- [ ] Có convention đặt env files, secrets template và không commit secret thật.
- [ ] Có CODEOWNERS hoặc contributing notes nếu team có nhiều người cùng làm.

### Technical Notes

- Không cần tạo thêm repository ở giai đoạn MVP.
- Nếu sau này backend/mobile/infra có release cadence khác nhau hoặc team ownership tách biệt, lúc đó mới cân nhắc split repo.
- CI nên dùng path-based workflow để monorepo không làm chậm pipeline.

---

# Summary

## All Tickets by Epic

Each section below maps directly to a Linear Milestone. The `Phase` column should be used with labels `phase:1`, `phase:2`, `phase:3`; when a phase starts, move its tickets from `Backlog` to `Planned` in Linear.


### Epic 1: Authentication & User Access (3 tickets)

| ID | Title | Priority | Phase | Blocked By |
| --- | --- | --- | ---: | --- |
| TIM-AUTH-001 | Configure Cognito User Pool and App Client | P0 | 1 | - |
| TIM-AUTH-002 | Integrate API Gateway Cognito Authorizer | P0 | 1 | TIM-AUTH-001 |
| TIM-AUTH-003 | Implement Backend User Context Middleware | P0 | 1 | TIM-AUTH-002 |

### Epic 2: API Core & Backend Service (4 tickets)

| ID | Title | Priority | Phase | Blocked By |
| --- | --- | --- | ---: | --- |
| TIM-API-001 | Define API Contract for MVP | P0 | 1 | - |
| TIM-API-002 | Implement Backend Service Skeleton | P0 | 1 | TIM-API-001 |
| TIM-API-003 | Route API Gateway to ALB/Backend | P0 | 1 | TIM-API-002, TIM-INFRA-003 |
| TIM-API-004 | Implement Standard Error Handling and Request Validation | P1 | 1 | TIM-API-002 |

### Epic 3: Infrastructure, Compute & Scaling (5 tickets)

| ID | Title | Priority | Phase | Blocked By |
| --- | --- | --- | ---: | --- |
| TIM-INFRA-001 | Design Cost-Optimized VPC, Subnets, Security Groups | P0 | 1 | - |
| TIM-INFRA-002 | Provision ECR Repository and Image Policy | P0 | 1 | - |
| TIM-INFRA-003 | Provision Cost-Optimized ALB, ECS Service and EC2 Capacity | P0 | 1 | TIM-INFRA-001, TIM-INFRA-002, TIM-API-002 |
| TIM-INFRA-004 | Configure Auto Scaling Policies | P1 | 2 | TIM-INFRA-003 |
| TIM-INFRA-005 | Setup LocalStack Dev Environment | P0 | 1 | TIM-INFRA-001, TIM-INFRA-002 |

### Epic 4: Data Storage & File Delivery (4 tickets)

| ID | Title | Priority | Phase | Blocked By |
| --- | --- | --- | ---: | --- |
| TIM-STOR-001 | Design DynamoDB Data Model | P0 | 1 | TIM-API-001 |
| TIM-STOR-002 | Implement DynamoDB Repository Layer | P0 | 1 | TIM-STOR-001, TIM-API-002, TIM-INFRA-005 |
| TIM-STOR-003 | Implement S3 Presigned URL Upload Flow | P0 | 1 | TIM-AUTH-003, TIM-STOR-002, TIM-INFRA-005 |
| TIM-STOR-004 | Configure CloudFront for File Delivery | P1 | 2 | TIM-STOR-003 |

### Epic 5: Async Processing & Notifications (4 tickets)

| ID | Title | Priority | Phase | Blocked By |
| --- | --- | --- | ---: | --- |
| TIM-ASYNC-001 | Define Event and Queue Contract | P1 | 1 | TIM-API-001 |
| TIM-ASYNC-002 | Implement EventBridge Publisher | P1 | 2 | TIM-ASYNC-001, TIM-API-002 |
| TIM-ASYNC-003 | Implement SQS Consumer Worker | P1 | 2 | TIM-ASYNC-001, TIM-INFRA-005 |
| TIM-ASYNC-004 | Implement SNS Push Notification Flow | P1 | 2 | TIM-AUTH-003, TIM-STOR-002, TIM-INFRA-005 |

### Epic 6: CI/CD, Release & Observability (6 tickets)

| ID | Title | Priority | Phase | Blocked By |
| --- | --- | --- | ---: | --- |
| TIM-CICD-001 | Build and Test Pipeline with GitHub Actions for Monorepo | P0 | 1 | TIM-API-002 |
| TIM-CICD-002 | Push Docker Image to ECR | P0 | 1 | TIM-CICD-001, TIM-INFRA-002 |
| TIM-CICD-003 | Rolling Update Deployment to ECS | P0 | 1 | TIM-CICD-002, TIM-INFRA-003 |
| TIM-CICD-004 | Add Centralized Logging and Metrics | P1 | 2 | TIM-INFRA-003, TIM-API-002 |
| TIM-CICD-005 | Security Baseline and Secret Management | P1 | 2 | TIM-INFRA-003 |
| TIM-CICD-006 | Organize Monorepo Boundaries and Developer Commands | P1 | 1 | - |

---

## Summary Statistics

| Epic | P0 | P1 | P2 | Tickets | Story Points |
| --- | ---: | ---: | ---: | ---: | ---: |
| Authentication & User Access | 3 | 0 | 0 | 3 | 13 |
| API Core & Backend Service | 3 | 1 | 0 | 4 | 18 |
| Infrastructure, Compute & Scaling | 4 | 1 | 0 | 5 | 25 |
| Data Storage & File Delivery | 3 | 1 | 0 | 4 | 20 |
| Async Processing & Notifications | 0 | 4 | 0 | 4 | 16 |
| CI/CD, Release & Observability | 3 | 3 | 0 | 6 | 24 |
| **Total** | **16** | **10** | **0** | **26** | **116** |

---

## Delivery Projections

**Baseline Assumption:** 5 FTEs delivering ~45 SP per 2-week sprint. Velocity đã trừ hao cho review, QA, deploy, AWS configuration, và unknowns từ TIM/architecture.

| Team Size | SP/Sprint | Sprints | Weeks | Months |
| ---: | ---: | ---: | ---: | ---: |
| 3 FTEs | 27 | 4.3 | 8.6 | 2.2 |
| 4 FTEs | 36 | 3.2 | 6.4 | 1.6 |
| 5 FTEs | 45 | 2.6 | 5.2 | 1.3 |
| 6 FTEs | 54 | 2.2 | 4.4 | 1.1 |

### Caveats

- Nội dung TIM chi tiết chưa được đọc trực tiếp từ Google Doc trong bản draft này, nên scope nghiệp vụ có thể thay đổi.
- Architecture dùng nhiều AWS managed services; cần thời gian setup IAM, networking, secrets và môi trường staging.
- Push notification APNs/FCM phụ thuộc certificate/key và app bundle/package setup.
- CloudFront private delivery có thể tăng complexity nếu file cần authorization chặt.
- Không setup 3 HA/AZ trong MVP/dev để tránh chi phí cao; chấp nhận availability thấp hơn production-grade architecture.
- ECS on EC2 + Auto Scaling phức tạp hơn ECS Fargate; cần chốt vận hành và cost trước khi triển khai.
- Zero-downtime rolling update phụ thuộc health check và app startup time ổn định.
- Vì chỉ có một repo, cần path-based CI và folder convention rõ để tránh monorepo bị rối khi backend/mobile/infra cùng phát triển.
- LocalStack giúp dev nhanh nhưng vẫn cần AWS dev/staging thật để verify Cognito, API Gateway, CloudFront, ECS/ALB/ASG và push notification.

**Recommendation:** Dùng Linear Milestone cho Epic, không dùng Milestone cho Cycle/Phase. Phase nên quản bằng status: ticket chưa làm để `Backlog`, ticket thuộc phase hiện tại chuyển sang `Planned`, sau đó đi qua `In Progress` → `In Review/QA` → `Done`.

**Delivery Recommendation:** Không cần tạo thêm repo ở MVP. Giữ `ManInTheHood/meomeo` làm monorepo chính, tách bằng folder `backend/`, `meomeo_flutter_app/`, `AI_CONTEXT/`, `.github/workflows/` và dùng path-based CI. Nên chia MVP thành 2 track song song: backend/API/auth/storage và infrastructure/CI/CD. Phase 1 khóa scope ở LocalStack dev environment, authentication, API core, DynamoDB, S3 presigned upload, ALB/ECS/ECR cost-optimized single-AZ và rolling deploy; EventBridge/SQS/SNS, CloudFront private delivery, autoscaling tuning và full observability để Phase 2 nếu timeline gấp.

---

## Phase Overview

### Phase 1: Core MVP

**Linear action:** Move all Phase 1 tickets from `Backlog` to `Planned` when Phase 1 starts. Keep Milestone as the ticket's Epic.

- Cognito authentication và API Gateway authorizer.
- API contract, backend skeleton, health check, validation/error model.
- Cost-optimized AWS dev/MVP infra: single-AZ mặc định, capacity thấp, không setup 3 HA.
- DynamoDB data model và repository layer.
- S3 presigned upload flow.
- GitHub Actions build/test, push image, rolling deployment.
- Monorepo boundaries, README commands, path-based CI cho `backend/` và `meomeo_flutter_app/`.

### Phase 2: Enhanced Features

**Linear action:** Keep Phase 2 tickets in `Backlog` during Phase 1. Move them to `Planned` only when Phase 2 starts.

- Auto Scaling policy tuning và staging load test.
- CloudFront delivery, signed URL/cookie nếu cần private file.
- EventBridge publisher, SQS worker, DLQ.
- SNS push notification APNs/FCM.
- Centralized logging, dashboard, alerts, runbook.
- Security baseline và secret management hardening.

### Phase 3: Optional / Fast-follow

**Linear action:** Keep Phase 3 tickets in `Backlog` unless the team explicitly pulls them into scope.

- Advanced monitoring/SLO, distributed tracing.
- WAF/rate limit tại API Gateway hoặc CloudFront.
- Blue/green deployment hoặc canary release.
- Cost optimization cho DynamoDB, EC2 ASG, CloudFront.
- Multi-environment promotion workflow dev -> staging -> prod.

---

Document created: May 2026  
Last updated: May 18, 2026
