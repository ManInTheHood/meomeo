# Backlog V3

## Ticket: Split Terraform Environments Into Dev And Prod

### Description

Separate Terraform infrastructure configuration into explicit `dev` and `prod` environments before continuing Cognito work. Each environment must be independently deployable, have isolated state/configuration, and support environment-specific values for resources such as Cognito callback/logout URLs, domains, naming, token settings, and app/backend environment variables.

This ticket blocks the Cognito setup ticket because the Cognito module should be wired once through reusable environment structure instead of being finalized only for `dev`.

### Priority

High

### Blocks

- Cognito setup for signup, login, refresh token, password policy, Hosted UI, and app client configuration.

### Acceptance Criteria

- Terraform has separate environment folders for `dev` and `prod`.
- `dev` and `prod` can be initialized/planned independently.
- Environment-specific variables are defined for names, domains, callback URLs, logout URLs, and other client/backend configuration values.
- Shared modules remain reusable and do not hardcode `dev`-only values.
- Terraform outputs needed by frontend/mobile and backend are available per environment.
- Documentation explains how to deploy or plan each environment separately.
- Cognito ticket can consume this structure without redesigning environment layout.

### Technical Notes

- Prefer keeping shared infrastructure logic in `backend/terraform/modules/*`.
- Use environment folders such as `backend/terraform/envs/dev` and `backend/terraform/envs/prod`.
- Consider separate backend state configuration per environment before real prod deployment.
- Avoid copying large blocks if a small environment variable layer can keep modules reusable.
- Review existing `backend/terraform/envs/dev/main.tf` for hardcoded `environment = "local"` values that may not match intended environment names.
