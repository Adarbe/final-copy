# provider "random" {
#   version = "~> 2.1"
# }

# provider "local" {
#   version = "~> 1.2"
# }

# provider "null" {
#   version = "~> 2.1"
# }

# provider "template" {
#   version = "~> 2.1"
# }

# data "aws_eks_cluster" "cluster" {
#   name = module.eks.cluster_id
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = module.eks.cluster_id
# }

# provider "kubernetes" {
#   host                   = "${data.aws_eks_cluster.cluster.endpoint}"
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
#   token                  = data.aws_eks_cluster_auth.cluster.token
#   load_config_file       = false
#   version                = "~> 1.10"
# }


# locals {
#   cluster_name = "final-project-eks-${random_string.suffix.result}"
# }

# resource "random_string" "suffix" {
#   length  = 8
#   special = false
# }

# # CIDR will be "My IP" \ all Ips from which you need to access the worker nodes
# resource "aws_security_group" "worker_group_mgmt_one" {
#   name_prefix = "worker_group_mgmt_one"
#   vpc_id = "${aws_vpc.final-project.id}"

#   ingress {
#     from_port = 22
#     to_port   = 22
#     protocol  = "tcp"

#     cidr_blocks = [
#       "10.0.0.0/16",
#       "79.176.75.203/32"
#     ]
#   }
# }

# module "eks" {
#   source       = "terraform-aws-modules/eks/aws"
#   cluster_name = local.cluster_name
#   #TODO Ssbnet id
#   subnets = ["${aws_subnet.pubsub[0].id}", "${aws_subnet.pubsub[1].id}","${aws_subnet.pubsub[2].id}"]

#   tags = {
#     Environment = "test"
#     GithubRepo  = "terraform-aws-eks"
#     GithubOrg   = "terraform-aws-modules"
#   }

#   vpc_id = "${aws_vpc.final-project.id}"

#   # TODO Worker group 1
#   # One Subnet
#   worker_groups = [
#     {
#       name                          = "worker-group-1"
#       instance_type                 = "t2.medium"
#       additional_userdata           = "echo foo bar"
#       asg_desired_capacity          = 3
#       additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
#     }
#   ]

# }