provider "random" {
  version = "~> 2.1"
}

provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = "${data.aws_eks_cluster.cluster.endpoint}"
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.10"
}


locals {
  cluster_name = "final-project-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

# CIDR will be "My IP" \ all Ips from which you need to access the worker nodes
resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id = "${aws_vpc.final-project.id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/16",
      "79.176.75.203/32"
    ]
  }
}

module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = local.cluster_name
  subnets = ["${aws_subnet.pubsub[0].id}", "${aws_subnet.pubsub[1].id}","${aws_subnet.pubsub[2].id}"]

  tags = {
    Environment = "test"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  vpc_id = "${aws_vpc.final-project.id}"

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t2.medium"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 3
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    }
  ]
}














# Jenkins IAM Policies, Role+Policy Attachements, & the Role itself to attach to Jenkins

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "jenkins_eks_profile"
  role = "${aws_iam_role.jenkins_iam_role.name}"
}

#A shared IAM role for jenkins which has two policy documents attached. IAM stuff & Power User Access.
#I added the region in the name
resource "aws_iam_role" "jenkins_iam_role" {
  name = "jenkins_iam_role"
  path = "/"
  assume_role_policy = "${data.aws_iam_policy_document.jenkins-assume-role-policy.json}"
}
# Needed to assume an instance role
data "aws_iam_policy_document" "jenkins-assume-role-policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  }
}

#Lets just give power user access to avoid permission issues.
#This is something to revisit going into production on what IAM perms you actually need.
#@todo It's is on you to restrict this jenkins role to your security requirements.
resource "aws_iam_role_policy_attachment" "poweruser-attach" {
  role = "${aws_iam_role.jenkins_iam_role.name}"
  policy_arn = "${aws_iam_policy.jenkins-iam-control-policy.arn}"
}

resource "aws_iam_role_policy_attachment" "iam-control-attach" {
  role = "${aws_iam_role.jenkins_iam_role.name}"
  policy_arn = "${aws_iam_policy.jenkins-iam-control-policy.arn}"
}

resource "aws_iam_policy" "jenkins-iam-control-policy" {
  name = "jenkins-iam-control-policy-iam-control"
  description = "Give some control over IAM "
  policy = "${data.aws_iam_policy_document.jenkins-iam-control-policy.json}"
}

#Needed to provision resources in AWS from the Jenkins instance
data "aws_iam_policy_document" "jenkins-iam-control-policy" {
  statement {
    effect = "Allow"
    actions = [
      "iam:AddRoleToInstanceProfile",
      "iam:AttachRolePolicy",
      "iam:CreatePolicy",
      "iam:CreateRole",
      "iam:CreateInstanceProfile",
      "iam:DeletePolicy",
      "iam:DeleteRole",
      "iam:DeleteRolePolicy",
      "iam:DeleteInstanceProfile",
      "iam:DetachRolePolicy",
      "iam:PassRole",
      "iam:GetRole",
      "iam:GetGroup",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:GetRolePolicy",
      "iam:GetInstanceProfile",
      "iam:ListAttachedRolePolicies",
      "iam:ListEntitiesForPolicy",
      "iam:ListInstanceProfilesForRole",
      "iam:ListRolePolicies",
      "iam:ListRoles",
      "iam:PutRolePolicy",
      "iam:RemoveRoleFromInstanceProfile"
    ]
    resources = ["*"]
  }
}