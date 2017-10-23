
variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-west-1"
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
  default     = "aws/codebuild/golang:1.7.3"
}
