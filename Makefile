PROJECT_NAME := "fubar"
GO_FILES = $(shell find ./ -type f -name '*.go')


.PHONY: deps
deps:
	go get github.com/coreos/go-systemd/daemon

.PHONY: packer
packer:
	packer build packer.json

.PHONY: terraform_apply
terraform_apply:
	terraform apply -var 'key_name=terraform' -var 'public_key_path=/home/vagrant/.ssh/fubar.pub'

.PHONY: terraform_destroy
terraform_destroy:
	terraform destroy -var 'key_name=terraform' -var 'public_key_path=/home/vagrant/.ssh/fubar.pub'

.PHONY: provision_ci
provision_ci:
	terraform apply -var 'key_name=terraform' -var 'public_key_path=/home/vagrant/.ssh/fubar.pub'

.PHONY: init_keys
init_keys:
	#@ test -n "$(GITHUB_TOKEN)" || echo "GITHUB_TOKEN is required,AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY"; exit 1
	#@ test -n "$(AWS_ACCESS_KEY_ID)" || echo "AWS_ACCESS_KEY_ID is required,AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY"; exit 1
	#@ test -n "$(AWS_SECRET_ACCESS_KEY)" || echo "AWS_SECRET_ACCESS_KEY is required,AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY"; exit 1
	ssh-keygen -N '' -f "$$HOME/.ssh/$(PROJECT_NAME)"
	cp "$$HOME/.ssh/$(PROJECT_NAME).pub" "$(shell pwd)"

.PHONY: build
build: $(GO_GILES) deps
	go build
