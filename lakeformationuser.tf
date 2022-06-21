resource "aws_iam_user" "lakeformationuser" {
  name = "lfuser"

  tags = {
    "env"         = "nonprod"
    "application" = "myspot"
    "createdby"   = "ion"
  }
}

resource "aws_iam_access_key" "lakeformationuserkey" {
  user = aws_iam_user.lakeformationuser.name
}

resource "aws_iam_user_policy" "lakeformationuser_admin_lf" {
  name = "lf_policy"
  user = aws_iam_user.lakeformationuser.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
                        "lakeformation:*",
                "cloudtrail:DescribeTrails",
                "cloudtrail:LookupEvents",
                "glue:GetDatabase",
                "glue:GetDatabases",
                "glue:CreateDatabase",
                "glue:UpdateDatabase",
                "glue:DeleteDatabase",
                "glue:GetConnections",
                "glue:SearchTables",
                "glue:GetTable",
                "glue:CreateTable",
                "glue:UpdateTable",
                "glue:DeleteTable",
                "glue:GetTableVersions",
                "glue:GetPartitions",
                "glue:GetTables",
                "glue:GetWorkflow",
                "glue:ListWorkflows",
                "glue:BatchGetWorkflows",
                "glue:DeleteWorkflow",
                "glue:GetWorkflowRuns",
                "glue:StartWorkflowRun",
                "glue:GetWorkflow",
                "s3:ListBucket",
                "s3:GetBucketLocation",
                "s3:ListAllMyBuckets",
                "s3:GetBucketAcl",
                "iam:ListUsers",
                "iam:ListRoles",
                "iam:GetRole",
                "iam:GetRolePolicy",
                "*",
                "iam:PassRole",
                "lakeformation:PutDataLakeSettings",
                "lakeformation:GetDataAccess"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}