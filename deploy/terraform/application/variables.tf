variable "ssh_pubkey_file" {
    description = "Path to an SSH public key"
    default = "~/.ssh/fubar.pub"
}

variable "default_tags" {
  type = "map"
  default = {
    Project = "fubar"
  }
}

variable "aws_vpc_id" {
    default = "vpc-0c03c765"
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

variable "availability_zone" {
    description = "The availability zone"
    default = "eu-west-2a"
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

