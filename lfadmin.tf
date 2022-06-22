resource "aws_lakeformation_data_lake_settings" "lfuser_datalake_admin" {
  admins = [aws_iam_user.lakeformationuser.arn]

  create_database_default_permissions {
    permissions = ["ALL"]
    principal   = "IAM_ALLOWED_PRINCIPALS"
  }

  create_table_default_permissions {
    permissions = ["ALL"]
    principal   = "IAM_ALLOWED_PRINCIPALS"


  }
}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["dms.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "role_for_dl" {
  name                  = "instance_role"
  assume_role_policy    = data.aws_iam_policy_document.instance-assume-role-policy.json
  force_detach_policies = true
  managed_policy_arns   = ["arn:aws:iam::aws:policy/SecretsManagerReadWrite", "arn:aws:iam::aws:policy/AmazonS3FullAccess"]
}