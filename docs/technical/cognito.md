## Cognito Hosted UI Configuration

The Auth Terraform module creates a Cognito User Pool, a public app client for Authorization Code + PKCE, direct SDK sign-in with SRP, refresh-token auth, and a Hosted UI domain.

Users sign up and log in with email and password. The backend should treat the access token `sub` claim as the stable user principal and should not use `email` for ownership checks.

Each Terraform environment defines its own Cognito values in
`backend/terraform/envs/<env>/terraform.tfvars` and outputs the values needed by
clients and the backend.

Get the generated values after `terraform apply` from the environment directory:
```bash
cd backend/terraform/envs/dev
terraform output
```

For production, use `backend/terraform/envs/prod` and confirm callback/logout
URLs before applying.

Flutter / mobile app environment variables:
```bash
COGNITO_REGION=ap-southeast-1
COGNITO_USER_POOL_ID=<terraform output cognito_user_pool_id>
COGNITO_APP_CLIENT_ID=<terraform output cognito_app_client_id>
COGNITO_DOMAIN=<terraform output cognito_domain>
COGNITO_REDIRECT_SIGN_IN=meomeo://auth/callback
COGNITO_REDIRECT_SIGN_OUT=meomeo://auth/logout
COGNITO_RESPONSE_TYPE=code
COGNITO_SCOPES="openid email profile"
COGNITO_AUTH_FLOWS="ALLOW_USER_SRP_AUTH ALLOW_REFRESH_TOKEN_AUTH"
```

Dev allowed callback/logout URLs:
```bash
COGNITO_REDIRECT_SIGN_IN=meomeo://auth/callback
COGNITO_REDIRECT_SIGN_OUT=meomeo://auth/logout
WEB_REDIRECT_SIGN_IN=http://localhost:3000/auth/callback
WEB_REDIRECT_SIGN_OUT=http://localhost:3000/auth/logout
```

Prod allowed callback/logout URLs:
```bash
COGNITO_REDIRECT_SIGN_IN=meomeo://auth/callback
COGNITO_REDIRECT_SIGN_OUT=meomeo://auth/logout
WEB_REDIRECT_SIGN_IN=https://app.meomeo.com/auth/callback
WEB_REDIRECT_SIGN_OUT=https://app.meomeo.com/auth/logout
```

Backend environment variables:
```bash
AWS_REGION=ap-southeast-1
COGNITO_USER_POOL_ID=<terraform output cognito_user_pool_id>
COGNITO_APP_CLIENT_ID=<terraform output cognito_app_client_id>
COGNITO_ISSUER=<terraform output cognito_issuer>
COGNITO_JWKS_URI=<terraform output cognito_jwks_uri>
COGNITO_TOKEN_USE=access
```

Backend token validation must require `sub`, `token_use=access`, `client_id`, `iss`, and `exp`. Optional authorization inputs are `scope` and `cognito:groups`.

Username decision: Cognito uses email as the username with case-insensitive
matching. The backend should keep using `sub` as the stable authorization
principal because email can change.

Flutter direct sign-in should use SRP through the Cognito SDK. The app client
allows `ALLOW_USER_SRP_AUTH` for email/password sign-in without sending the raw
password as plain API input, plus `ALLOW_REFRESH_TOKEN_AUTH` for session refresh.
