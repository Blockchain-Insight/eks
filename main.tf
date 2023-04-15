terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.23"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.16.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.7"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.profile
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

data "aws_iam_role" "cluster" {
  name = module.eks.cluster_iam_role_name
}

data "aws_subnets" "az_a" {
  filter {
    name   = "vpc-id"
    values = [module.vpc.vpc_id]
  }

  tags = {
    Name = "${var.cluster_name}-public-${var.region}a"
  }
}


data "aws_subnets" "az_b" {
  filter {
    name   = "vpc-id"
    values = [module.vpc.vpc_id]
  }
  tags = {
    Name = "${var.cluster_name}-public-${var.region}b"
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name           = var.cluster_name
  cidr           = var.vpc_cidr
  azs            = [for az in var.az : format("%s%s", var.region, az)]
  public_subnets = [cidrsubnet(var.vpc_cidr, 4, 1), cidrsubnet(var.vpc_cidr, 4, 2)]

  enable_dns_hostnames = true
  enable_dns_support   = true

  map_public_ip_on_launch = true

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
}

resource "aws_iam_policy" "policy" {
  name   = var.cluster_name
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AttachVolume",
        "ec2:CreateSnapshot",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:DeleteSnapshot",
        "ec2:DeleteTags",
        "ec2:DeleteVolume",
        "ec2:DescribeInstances",
        "ec2:DescribeSnapshots",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DetachVolume"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "attach" {
  name = var.cluster_name
  roles = [
    data.aws_iam_role.cluster.id
  ]
  policy_arn = aws_iam_policy.policy.arn
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [module.vpc.vpc_id]
  }
}

locals {
  subnet_ids_string = join(",", data.aws_subnets.subnets.ids)
  subnet_ids_list   = split(",", local.subnet_ids_string)
  depends_on        = [module.vpc]
}