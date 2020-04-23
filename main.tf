
provider "aws" {
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
  region = "us-east-1"
}

######### Resource ####################


resource "aws_vpc" "final-project" {
  cidr_block       = "10.0.0.0/16"
  tags = {
    Name = "final-project"
  }
  enable_dns_hostnames = true
  enable_dns_support   = true
}

data "aws_availability_zones" "available" {}

######### Data ####################

data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
      name = "name"
      values = [
        "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
    }

    filter {
      name = "virtualization-type"
      values = ["hvm"]
    }

    owners = ["099720109477"]# Canonical
  }


######### IAM ####################


# Create an IAM role for the auto-join
resource "aws_iam_role" "consul-join" {
  name               = "final-consul-join"
  assume_role_policy = file("${path.module}/consul/templates/policies/assume-role.json")
}

# Create the policy
resource "aws_iam_policy" "consul-join" {
  name        = "final-consul-join"
  description = "Allows Consul nodes to describe instances for joining."
  policy      = file("${path.module}/consul/templates/policies/describe-instances.json")
}

# Attach the policy
resource "aws_iam_policy_attachment" "consul-join" {
  name       = "final-consul-join"
  roles      = ["${aws_iam_role.consul-join.name}"]
  policy_arn = aws_iam_policy.consul-join.arn
}

# Create the instance profile
resource "aws_iam_instance_profile" "consul-join" {
  name = "final-consul-join"
  role = aws_iam_role.consul-join.name
}



######### IAM Jenkins####################
## Jenkins IAM Resources ##
resource "aws_iam_role" "final-jenkins_eks" {
  name = "final-jenkins_eks"
  assume_role_policy = file("${path.module}/eks/templates/policies/eks_jenkins_iam_role.json")
}

# Create the policy
resource "aws_iam_policy" "final-jenkins_eks" {
  name = "final-jenkins_eks"
  policy = file("${path.module}/eks/templates/policies/eks_jenkins_iam_policy.json")
}


# Attach the policy
resource "aws_iam_policy_attachment" "final-jenkins_eks" {
  name       = "final-jenkins_eks"
  roles      = ["${aws_iam_role.consul-join.name}", "${aws_iam_role.final-jenkins_eks.name}"]
  policy_arn = aws_iam_policy.final-jenkins_eks.arn
}

# Create the instance profile
resource "aws_iam_instance_profile" "final-jenkins_eks" {
  name  = "final-jenkins_eks"
  role = aws_iam_role.final-jenkins_eks.name
}

