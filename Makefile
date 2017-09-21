.PHONY: packer
packer:
	packer build packer.json

.PHONY: terraform_apply
terraform_apply:
	terraform apply -var 'key_name=terraform' -var 'public_key_path=/home/vagrant/.ssh/fubar.pub'

.PHONY: terraform_destroy
terraform_destroy:
	terraform destroy -var 'key_name=terraform' -var 'public_key_path=/home/vagrant/.ssh/fubar.pub'
