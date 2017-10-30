terraform {
    backend "s3" {
        bucket = "something.andrewrea.co.uk"
        key    = "network/application/terraform.tfstate"
        region = "eu-west-2"
    }
}

# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_key_pair" "fubar" {
    key_name = "fubar-key"
    public_key = "${file(var.ssh_pubkey_file)}"
}

data "aws_vpc" "main" {
  id = "${var.aws_vpc_id}"
}

data "aws_route_table" "external" {
  vpc_id = "${var.aws_vpc_id}"
}

data "aws_internet_gateway" "default" {
  filter {
    name = "attachment.vpc-id"
    values = ["${var.aws_vpc_id}"]
  }
}

# TODO: figure out how to support creating multiple subnets, one for each
# availability zone.
data "aws_subnet" "main" {
    id = "subnet-5b977f20"
}


resource "aws_route_table_association" "external-main" {
    subnet_id = "${data.aws_subnet.main.id}"
    route_table_id = "${data.aws_route_table.external.id}"
}

resource "aws_security_group" "load_balancers" {
  name = "load_balancers"
  description = "Allows all traffic"
  vpc_id = "${data.aws_vpc.main.id}"

  # TODO: do we need to allow ingress besides TCP 80 and 443?
  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  # TODO: this probably only needs egress to the ECS security group.
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs" {
  name = "ecs"
  description = "Allows all traffic"
  vpc_id = "${data.aws_vpc.main.id}"

  # TODO: remove this and replace with a bastion host for SSHing into
  # individual machines.
  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      security_groups = ["${aws_security_group.load_balancers.id}"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "main" {
    name = "${var.ecs_cluster_name}"
}

resource "aws_autoscaling_group" "ecs-cluster" {
    availability_zones = ["${var.availability_zone}"]
    name = "ECS ${var.ecs_cluster_name}"
    min_size = "${var.autoscale_min}"
    max_size = "${var.autoscale_max}"
    desired_capacity = "${var.autoscale_desired}"
    health_check_type = "EC2"
    launch_configuration = "${aws_launch_configuration.ecs.name}"
    vpc_zone_identifier = ["${data.aws_subnet.main.id}"]
}

resource "aws_launch_configuration" "ecs" {
  name = "ECS ${var.ecs_cluster_name}"
  image_id = "${lookup(var.amis, var.aws_region)}"
  instance_type = "${var.instance_type}"
  security_groups = ["${aws_security_group.ecs.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.ecs.name}"
  #
  key_name = "${aws_key_pair.fubar.key_name}"
  associate_public_ip_address = true
  user_data = "#!/bin/bash\necho ECS_CLUSTER='${var.ecs_cluster_name}' > /etc/ecs/ecs.config && `aws ecr get-login --region $AWS_DEFAULT_REGION`"
}

resource "aws_iam_role" "ecs_host_role" {
  name = "ecs_host_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ecs.amazonaws.com",
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs_instance_role_policy" {
  name = "ecs_instance_role_policy"
  role = "${aws_iam_role.ecs_host_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "ecs:*",
        "ecr:*"
      ],
      "Resource": ["*"]
    }
  ]
}
EOF
}

resource "aws_iam_role" "ecs_service_role" {
  name = "ecs_service_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ecs.amazonaws.com",
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs_service_role_policy" {
    name = "ecs_service_role_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "ec2:Describe*",
        "ec2:AuthorizeSecurityGroupIngress"
      ],
      "Resource": ["*"]
    }
  ]
}
EOF
    role = "${aws_iam_role.ecs_service_role.id}"
}

resource "aws_iam_instance_profile" "ecs" {
    name = "ecs-instance-profile"
    role = "${aws_iam_role.ecs_host_role.name}"
}

resource "aws_elb" "fubar-http" {
  name = "fubar-http-elb"
  security_groups = ["${aws_security_group.load_balancers.id}"]
  subnets = ["${data.aws_subnet.main.id}"]

  listener {
      lb_protocol = "http"
      lb_port = 80

      instance_protocol = "http"
      instance_port = 45000
  }

  health_check {
      healthy_threshold = 3
      unhealthy_threshold = 2
      timeout = 3
      target = "HTTP:45000/"
      interval = 5
  }

  cross_zone_load_balancing = true
}

resource "aws_ecs_task_definition" "fubar-http" {
  family = "fubar-http"
  container_definitions = "${file("deploy/terraform/application/task-definitions/fubar-http.json")}"
}

resource "aws_ecs_service" "fubar-http" {
  name = "fubar-http"
  cluster = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.fubar-http.arn}"
  iam_role = "${aws_iam_role.ecs_service_role.arn}"
  desired_count = 2
  depends_on = ["aws_iam_role_policy.ecs_service_role_policy"]

  load_balancer {
      elb_name = "${aws_elb.fubar-http.id}"
      container_name = "fubar-http"
      container_port = 45000
  }
}
