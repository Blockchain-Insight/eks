module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "v19.12.0"

  cluster_name                   = var.cluster_name
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = true
  create_kms_key                 = false
  cluster_encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = "arn:aws:kms:eu-central-1:508468563203:key/b207fc6f-66c4-4aff-b684-d8da24759c76"
  }
  cluster_addons = {
    coredns = {
      preserve    = true
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.public_subnets
  control_plane_subnet_ids = module.vpc.public_subnets

  manage_aws_auth_configmap = true
  cluster_identity_providers = {
    sts = {
      client_id = "sts.amazonaws.com"
    }
  }

  iam_role_additional_policies = {
    additional = aws_iam_policy.additional.arn
  }

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_ARM_64"
    disk_size      = var.disk_size
    instance_types = var.instance_type

    iam_role_additional_policies = {
      additional = aws_iam_policy.additional.arn
    }
  }

  eks_managed_node_groups = {
    validator = {
      name           = "validator"
      disk_size      = var.disk_size
      subnet_ids     = module.vpc.public_subnets
      min_size       = var.min_capacity
      max_size       = var.max_capacity
      desired_size   = var.desired_capacity
      instance_types = var.instance_type
      labels = {
        Environment = "${var.cluster_name}-${var.region}"
        Role        = "validator"
      }

      tags = merge(var.tags,
        {
          "role" = "validator"
        }
      )

      taints = [
        {
          key    = "dedicated"
          value  = "validator"
          effect = "NO_SCHEDULE"
        }
      ]
    },

    full_node = {
      name           = "full-node"
      disk_size      = var.disk_size
      subnet_ids     = module.vpc.public_subnets
      min_size       = var.min_capacity
      max_size       = var.max_capacity
      desired_size   = var.desired_capacity
      instance_types = var.instance_type
      labels = {
        Environment = "${var.cluster_name}-${var.region}"
        Role        = "full-node"
      }

      tags = merge(var.tags,
        {
          "role" = "full-node"
        }
      )

      taints = [
        {
          key    = "dedicated"
          value  = "full-node"
          effect = "NO_SCHEDULE"
        }
      ]
    },

    infra = {
      name           = "infra"
      disk_size      = var.disk_size
      subnet_ids     = module.vpc.public_subnets
      min_size       = var.min_capacity
      max_size       = var.max_capacity
      desired_size   = var.desired_capacity
      instance_types = var.instance_type
      labels = {
        Environment = "${var.cluster_name}-${var.region}"
        Role        = "infra"
      }

      tags = merge(var.tags,
        {
          "role" = "infra"
        }
      )
    },
  }
}

resource "aws_iam_policy" "additional" {
  name = "${var.cluster_name}-additional"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
          "ssm:GetParameter*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}