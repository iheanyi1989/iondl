output "snowflake_storage_integration_id" {
  value = snowflake_storage_integration.integration.id
}

output "storage_aws_external_id" {
  value = snowflake_storage_integration.integration.storage_aws_external_id
}

output "storage_aws_iam_user_arn" {
  value = snowflake_storage_integration.integration.storage_aws_iam_user_arn
}

output "snowflake_db" {
  value = snowflake_database.db.name
}

output "snowflake_schema" {
  value = snowflake_schema.schema.name
}

# output "snowflake_stage" {
#   value     = snowflake_stage.example_stage
#   sensitive = true
# }

# output "snowflake_stage_integration" {
#   value = snowflake_stage.example_stage.storage_integration
# }


output "raw_bucket_arn" {
  value = aws_s3_bucket.lf-user-buckets[1].arn
}