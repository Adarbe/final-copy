
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

resource "aws_iam_instance_profile" "final-Jenkins_IAM_Profile" {
  name  = "final-Jenkins_Profile"
  role = "${aws_iam_role.Jenkins_IAM_Role.name}"
}
resource "aws_iam_role" "Jenkins_IAM_Role" {
  name = "final-Jenkins-Role"
#  description = 
  assume_role_policy = file("${path.module}/eks/templates/policies/eks_jenkins_iam_role.json")
}
resource "aws_iam_role_policy" "Jenkins_IAM_Policy" {
  name = "final-Jenkins-Policy"
  role = "${aws_iam_role.Jenkins_IAM_Role.id}"
  policy = file("${path.module}/eks/templates/policies/eks_jenkins_iam_policy.json")
}

# variable "iam_policy_arn" {
#   description = "IAM Policy to be attached to role"
#   type = "list"
# }

# # Then parse through the list using count
# resource "aws_iam_role_policy_attachment" "role-policy-attachment" {
#   role       = "${var.iam_role_name}"
#   count      = "${length(var.iam_policy_arn)}"
#   policy_arn = "${var.iam_policy_arn[count.index]}"
# }
