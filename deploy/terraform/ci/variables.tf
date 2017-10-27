variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-west-2"
}

variable "ci_bucket" {
  description = "The project owner"
  default     = "ci.fubar.andrewrea.co.uk"
}

variable "owner" {
  description = "The project owner"
  default     = "reaandrew"
}

variable "repository" {
  description = "The project name"
  default     = "fubar"
}

variable "aws_build_image" {
  description = "The docker image to use in AWS Build"
  default     = "aws/codebuild/docker:1.12.1"
}

variable "aws_account_id" {
    description = "the aws account id"
    default     = "776648872426"
}
