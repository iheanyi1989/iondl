resource "aws_iam_policy" "snowflake_access" {
  name        = "snowflake_access"
  description = "Snowflake"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Stmt1658418886649",
        "Action" : [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ],
        "Effect" : "Allow",
        "Resource" : "${output.raw_bucket_arn.value}/*"
      },
      {
        "Sid" : "Stmt1658418947340",
        "Action" : [
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ],
        "Effect" : "Allow",
        "Resource" : "${output.raw_bucket_arn.value}"
        "Condition" : {
          "StringLike" : {
            "s3:prefix" : "*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "snowflake_role" {
  name = "snowflake_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "${var.snowflake_account_arn}"
        },
        "Action" : "sts:AssumeRole",
        "Condition" : {
          "StringEquals" : {
            "sts:ExternalId" : "${var.snowflake_external_id}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "snowflake_access_attach" {
  role       = aws_iam_role.snowflake_role.name
  policy_arn = aws_iam_policy.snowflake_access.arn
}