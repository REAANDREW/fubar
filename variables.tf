variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.
Example: ~/.ssh/terraform.pub
DESCRIPTION
}

variable "default_tags" {
  type = "map"
  default = {
    Project = "fubar"
  }
}

variable "vpc_id" {
    description = "The VPC in which to deploy"
}

variable "key_name" {
  description = "Desired name of AWS key pair"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-west-1"
}

# Centos 7
variable "aws_amis" {
  default = {
    eu-west-1 = "ami-555aa12c"
  }
}
