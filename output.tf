output "snowflake_storage_integration_id" {
  value = snowflake_storage_integration.integration.id
}

output "storage_aws_external_id" {
  value = snowflake_storage_integration.integration.storage_aws_external_id
}

output "storage_aws_iam_user_arn" {
  value = snowflake_storage_integration.integration.storage_aws_iam_user_arn
}