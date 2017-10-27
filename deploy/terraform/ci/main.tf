terraform {
    backend "s3" {
        bucket = "something.andrewrea.co.uk"
        key    = "network/application/terraform.tfstate"
        region = "eu-west-2"
    }
}

provider "aws" {
  region     = "${var.aws_region}"
}

resource "aws_s3_bucket" "develop" {
  bucket = "${var.ci_bucket}"
  acl    = "private"
  force_destroy = true
}

resource "aws_iam_role" "codepipeline_role" {
  name = "fubar-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "fubar_codepipeline_policy"
  role = "${aws_iam_role.codepipeline_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": "s3:*",
      "Resource": [
        "${aws_s3_bucket.develop.arn}",
        "${aws_s3_bucket.develop.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters"
      ],
      "Resource": [
        "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:parameter/fubar-*"
      ]
    }
  ]
}
EOF
}

data "aws_ssm_parameter" "GITHUB_TOKEN" {
  name  = "fubar-github-token"
}

resource "aws_codepipeline" "develop" {
  name     = "tf-test-pipeline"
  role_arn = "${aws_iam_role.codepipeline_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.develop.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["fubar"]

      configuration {
        Owner      = "${var.owner}"
        Repo       = "${var.repository}"
        Branch     = "master"
        OAuthToken = "${data.aws_ssm_parameter.GITHUB_TOKEN.value}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["fubar"]
      version         = "1"

      configuration {
        ProjectName = "${var.repository}"
      }
    }
  }
}

resource "aws_iam_role" "codebuild_role" {
  name = "fubar-codebuild-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "codebuild_policy" {
  name        = "fubar-codebuild-policy"
  path        = "/service-role/"
  description = "Policy used in trust relationship with CodeBuild"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "codepipeline:GetPipeline",
        "s3:*",
        "ecr:GetAuthorizationToken"
      ]
    },
    {
        "Effect": "Allow",
        "Action": [
            "ecr:*"
        ],
        "Resource": [
            "arn:aws:ecr:eu-west-2:776648872426:repository/fubar"
        ]
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "codebuild_policy_attachment" {
  name       = "codebuild-policy-attachment"
  policy_arn = "${aws_iam_policy.codebuild_policy.arn}"
  roles      = ["${aws_iam_role.codebuild_role.id}"]
}

resource "aws_codebuild_project" "foo" {
  name         = "${var.repository}"
  description  = "${var.repository}"
  build_timeout      = "5"
  service_role = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "${var.aws_build_image}"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  source {
    type     = "CODEPIPELINE"
  }
}
