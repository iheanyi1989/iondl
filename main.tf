resource "snowflake_database" "db" {
  name = "TF_DEMO"
}
resource "snowflake_warehouse" "warehouse" {
  name           = "TF_DEMO"
  warehouse_size = "large"
  auto_suspend   = 60
}

resource "snowflake_storage_integration" "integration" {
  name                      = "storage"
  comment                   = "A storage integration."
  type                      = "EXTERNAL_STAGE"
  storage_provider          = "S3"
  enabled                   = true
  storage_allowed_locations = ["s3://ion-lakeformation-raw/input/"]
  storage_aws_role_arn      = "arn:aws:iam::384206995652:role/snowflake_role"
  #   storage_blocked_locations = [""]
  #   storage_aws_object_acl    = "bucket-owner-full-control"

  #   storage_aws_external_id  = "..."
  #   storage_aws_iam_user_arn = "...."

  # 

  # azure_tenant_id
}

resource "snowflake_stage" "example_stage" {
  name                = "EXAMPLE_STAGE"
  url                 = "s3://ion-lakeformation-raw/input/load/files"
  database            = snowflake_database.db.name
  schema              = "PUBLIC"
  storage_integration = snowflake_storage_integration.integration.name
}

resource "snowflake_stage_grant" "grant_example_stage" {
  database_name = snowflake_stage.example_stage.database
  schema_name   = snowflake_stage.example_stage.schema
  #   roles         = ["LOADER"]
  #   privilege     = "OWNERSHIP"
  #   stage_name    = snowflake_stage.example_stage.name
}

resource "snowflake_external_table" "external_table" {
  database = "TF_DEMO"
  schema   = "PUBLIC"
  name     = "external_table"
  comment  = "External table"
  column {
    as   = "customer"
    name = "id"
    type = "VARIANT"
  }
  file_format = "TYPE = JSON"
  #location = "@EXAMPLE_STAGE/path1/"
  location = "s3://ion-lakeformation-raw/input/load/files/path/"
}