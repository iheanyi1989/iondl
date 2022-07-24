# resource "aws_iam_user" "lakeformationuser" {
#   name = "lfuser"

#   tags = {
#     "env"         = "nonprod"
#     "application" = "myspot"
#     "createdby"   = "ion"
#   }
# }

# resource "aws_iam_access_key" "lakeformationuserkey" {
#   user = aws_iam_user.lakeformationuser.name
# }

# resource "aws_iam_user_policy" "lakeformationuser_admin_lf" {
#   name = "lf_policy"
#   user = aws_iam_user.lakeformationuser.name

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": [
#                         "lakeformation:*",
#                 "cloudtrail:DescribeTrails",
#                 "cloudtrail:LookupEvents",
#                 "glue:GetDatabase",
#                 "glue:GetDatabases",
#                 "glue:CreateDatabase",
#                 "glue:UpdateDatabase",
#                 "glue:DeleteDatabase",
#                 "glue:GetConnections",
#                 "glue:SearchTables",
#                 "glue:GetTable",
#                 "glue:CreateTable",
#                 "glue:UpdateTable",
#                 "glue:DeleteTable",
#                 "glue:GetTableVersions",
#                 "glue:GetPartitions",
#                 "glue:GetTables",
#                 "glue:GetWorkflow",
#                 "glue:ListWorkflows",
#                 "glue:BatchGetWorkflows",
#                 "glue:DeleteWorkflow",
#                 "glue:GetWorkflowRuns",
#                 "glue:StartWorkflowRun",
#                 "glue:GetWorkflow",
#                 "s3:ListBucket",
#                 "s3:GetBucketLocation",
#                 "s3:ListAllMyBuckets",
#                 "s3:GetBucketAcl",
#                 "iam:ListUsers",
#                 "iam:ListRoles",
#                 "iam:GetRole",
#                 "iam:GetRolePolicy",
#                 "*",
#                 "iam:PassRole",
#                 "lakeformation:PutDataLakeSettings",
#                 "lakeformation:GetDataAccess"
#       ],
#       "Effect": "Allow",
#       "Resource": "*"
#     }
#   ]
# }
# EOF
# }

# resource "aws_lakeformation_data_lake_settings" "lfuser_datalake_admin" {
#   admins = [aws_iam_user.lakeformationuser.arn]

#   create_database_default_permissions {
#     permissions = ["ALL"]
#     principal   = "IAM_ALLOWED_PRINCIPALS"
#   }

#   create_table_default_permissions {
#     permissions = ["ALL"]
#     principal   = "IAM_ALLOWED_PRINCIPALS"
#   }
# }

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
  managed_policy_arns = ["arn:aws:iam::aws:policy/SecretsManagerReadWrite",
  "arn:aws:iam::aws:policy/AmazonS3FullAccess"]
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
  assume_role_policy    = data.aws_iam_policy_document.dms_assume_role.json
  name                  = "dms-access-role"
  force_detach_policies = true
  managed_policy_arns = ["arn:aws:iam::aws:policy/SecretsManagerReadWrite",
    "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser",
    "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
  ]
}

resource "aws_iam_role" "dms-vpc-role" {
  force_detach_policies = true
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-vpc-role"
    managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
  ]
}

resource "aws_iam_role_policy_attachment" "dms-vpc-role-AmazonDMSVPCManagementRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
  role       = aws_iam_role.dms-vpc-role.name
}