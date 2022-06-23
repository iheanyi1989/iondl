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

data "aws_iam_policy_document" "instance-assume-role-policy-dl" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["dms.amazonaws.com", "dms.us-east-1.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "datalake-role" {
  name                  = "datalake_role"
  assume_role_policy    = data.aws_iam_policy_document.instance-assume-role-policy-dl.json
  force_detach_policies = true
  managed_policy_arns   = ["arn:aws:iam::aws:policy/SecretsManagerReadWrite", "arn:aws:iam::aws:policy/AmazonS3FullAccess"]
}

data "aws_iam_policy_document" "dms_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["dms.amazonaws.com", "dms.us-east-1.amazonaws.com"]
      type        = "Service"
    }
  }
}
resource "aws_iam_role" "dms-access-role" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-access-role"
  force_detach_policies = true
  managed_policy_arns = ["arn:aws:iam::aws:policy/SecretsManagerReadWrite",
  "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser",
  "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole",
  "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"]
}
