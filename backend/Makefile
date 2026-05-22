.PHONY: tf-init-dev tf-plan-dev tf-apply-dev tf-init-prod tf-plan-prod tf-apply-prod

# --- TERRAFORM DEV ---
tf-init-dev:
	cd terraform/envs/dev && terraform init

tf-plan-dev:
	cd terraform/envs/dev && terraform plan

tf-apply-dev:
	cd terraform/envs/dev && terraform apply -auto-approve

# --- TERRAFORM PROD ---
tf-init-prod:
	cd terraform/envs/prod && terraform init

tf-plan-prod:
	cd terraform/envs/prod && terraform plan

tf-apply-prod:
	cd terraform/envs/prod && terraform apply

# --- CLEANUP ---
clean:
	find . -type d -name ".terraform" -exec rm -rf {} +
	rm -f terraform/envs/dev/terraform.tfstate*
	rm -f terraform/envs/prod/terraform.tfstate*
