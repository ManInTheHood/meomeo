.PHONY: tf-init-dev tf-plan-dev tf-apply-dev

# --- TERRAFORM DEV ---
tf-init-dev:
	cd terraform/envs/dev && terraform init

tf-plan-dev:
	cd terraform/envs/dev && terraform plan

tf-apply-dev:
	cd terraform/envs/dev && terraform apply -auto-approve

# --- CLEANUP ---
clean:
	find . -type d -name ".terraform" -exec rm -rf {} +
	rm -f terraform/envs/dev/terraform.tfstate*
