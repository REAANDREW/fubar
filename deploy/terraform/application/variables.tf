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
    eu-west-1 = "ami-0d063c6b",
    eu-west-2 = "ami-c22236a6"
  }
}
