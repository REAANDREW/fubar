PROJECT_NAME := "fubar"
GO_FILES = $(shell find ./ -type f -name '*.go')


.PHONY: deps
deps:
	go get -t

.PHONY: packer
packer:
	AWS_PROFILE=fubar packer build packer.json

.PHONY: init_ci
init_ci:
	AWS_PROFILE=fubar terraform init deploy/terraform/ci

.PHONY: init_application
init_application:
	AWS_PROFILE=fubar terraform init deploy/terraform/application

.PHONY: provision_ci
provision_ci:
	AWS_PROFILE=fubar terraform apply deploy/terraform/ci

.PHONY: provision_application
provision_application:
	AWS_PROFILE=fubar terraform apply deploy/terraform/application
	
.PHONY: destroy_ci
destroy_ci:
	AWS_PROFILE=fubar terraform destroy --force deploy/terraform/ci

.PHONY: destroy_application
destroy_application:
	AWS_PROFILE=fubar terraform destroy --force deploy/terraform/application

.PHONY: build
build: $(GO_FILES) deps
	go build

.PHONY: build_production
build_production: $(GO_FILES) deps
	CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -a -installsuffix cgo -o fubar .
