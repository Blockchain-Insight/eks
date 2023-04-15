locals {
  aws_ebs_csi_controller_role_name                     = "${var.cluster_name}-aws-ebs-csi-controller"
  aws_ebs_csi_controller_service_account_name          = "ebs-csi-controller-sa"
  aws_ebs_csi_controller_namespace                     = "kube-system"
  aws_ebs_csi_controller_oidc_fully_qualified_subjects = ["system:serviceaccount:${local.aws_ebs_csi_controller_namespace}:${local.aws_ebs_csi_controller_service_account_name}"]
}

resource "aws_eks_addon" "aws_ebs_csi_driver" {
  cluster_name      = var.cluster_name
  addon_name        = "aws-ebs-csi-driver"
  resolve_conflicts = "OVERWRITE"

  service_account_role_arn = module.iam_assumable_role_ebs_csi_controller.iam_role_arn

  depends_on = [
    module.iam_assumable_role_ebs_csi_controller,
    aws_iam_role_policy_attachment.ebs_csi_controller_kms,
  ]
}

resource "aws_iam_policy" "ebs_csi_controller" {
  name_prefix = "${local.aws_ebs_csi_controller_role_name}-"
  description = "AWS EBS CSI controller policy for EKS cluster ${module.eks.cluster_name}"
  policy      = file("${path.module}/templates/iam-policy-aws-ebs-csi-controller.json.tpl")
}

module "iam_assumable_role_ebs_csi_controller" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.0"

  create_role                   = true
  role_name                     = local.aws_ebs_csi_controller_role_name
  provider_url                  = module.eks.cluster_oidc_issuer_url
  role_policy_arns              = [join("", aws_iam_policy.ebs_csi_controller[*].arn)]
  oidc_fully_qualified_subjects = local.aws_ebs_csi_controller_oidc_fully_qualified_subjects
}

resource "aws_iam_policy" "ebs_csi_controller_kms" {
  name_prefix = "${local.aws_ebs_csi_controller_role_name}-"
  description = "AWS KMS EBS CSI controller policy for EKS cluster ${module.eks.cluster_name}"
  policy = templatefile("${path.module}/templates/kms-key-for-encryption-on-ebs.json.tpl", {
    key_id = aws_kms_key.ebs.arn
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi_controller_kms" {
  role       = local.aws_ebs_csi_controller_role_name
  policy_arn = aws_iam_policy.ebs_csi_controller_kms.arn
  depends_on = [
    module.iam_assumable_role_ebs_csi_controller,
    aws_iam_policy.ebs_csi_controller
  ]
}

resource "aws_kms_key" "ebs" {
  description             = "Customer managed key to encrypt self managed node group volumes"
  deletion_window_in_days = 7
  policy = templatefile("${path.module}/templates/ebs_aws_kms_key_policy.tpl", {
    account_id           = var.account_id
    cluster_iam_role_arn = module.eks.cluster_iam_role_arn
  })
  enable_key_rotation = true
}

resource "aws_kms_alias" "ebs" {
  name          = "alias/${module.eks.cluster_name}-ebs"
  target_key_id = aws_kms_key.ebs.key_id
}
