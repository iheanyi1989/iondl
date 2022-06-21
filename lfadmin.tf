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