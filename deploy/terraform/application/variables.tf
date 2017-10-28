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
  default     = "eu-west-2"
}

# Centos 7
variable "aws_amis" {
  default = {
    eu-west-1 = "ami-0d063c6b",
    eu-west-2 = "ami-c22236a6"
  }
}

variable "availability_zones" {
    description = "The availability zone"
    default = ["eu-west-1a", "eu-west-2b"]
}

variable "ecs_cluster_name" {
    description = "The name of the Amazon ECS cluster."
    default = "fubar"
}

variable "amis" {
    description = "Which AMI to spawn. Defaults to the AWS ECS optimized images."
    # TODO: support other regions.
    default = {
        eu-west-2 = "ami-eb62708f"
    }
}

variable "autoscale_min" {
    default = "1"
    description = "Minimum autoscale (number of EC2)"
}

variable "autoscale_max" {
    default = "3"
    description = "Maximum autoscale (number of EC2)"
}

variable "autoscale_desired" {
    default = "2"
    description = "Desired autoscale (number of EC2)"
}


variable "instance_type" {
    default = "t2.micro"
}

