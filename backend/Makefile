.PHONY: local-up local-down tf-init-local tf-plan-local tf-apply-local

# --- DOCKER / LOCALSTACK ---
local-up:
	docker-compose up -d

local-down:
	docker-compose down

# --- TERRAFORM LOCAL ---
tf-init-local:
	cd terraform/envs/local && terraform init

tf-plan-local:
	cd terraform/envs/local && terraform plan

tf-apply-local:
	cd terraform/envs/local && terraform apply -auto-approve

# --- CLEANUP ---
clean:
	find . -type d -name ".terraform" -exec rm -rf {} +
	rm -f terraform/envs/local/terraform.tfstate*
