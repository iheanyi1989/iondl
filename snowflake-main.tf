

resource "snowflake_storage_integration" "integration" {
  name                      = upper("storage")
  comment                   = "Storage integration used to read files from S3 staging bucket"
  type                      = "EXTERNAL_STAGE"
  storage_provider          = "S3"
  enabled                   = true
  storage_allowed_locations = ["s3://ion-lakeformation-raw/"]
  storage_aws_role_arn      = resource.aws_iam_role.snowflake_role.arn
}

resource "snowflake_database" "db" {
  name = "TF_DEMO"
   comment = "Database for Snowflake Ingestion Pipeline (SIP) project" 
}

resource "snowflake_schema" "schema" {    
  database = snowflake_database.db.name
  name     = "TEST"
  comment  = "Schema from TEST source system"

  is_transient        = false
  is_managed          = false
}

resource "snowflake_stage" "example_stage" {
  name                = "EXAMPLE_STAGE"
  url                 = "s3://ion-lakeformation-raw/input/load/files"
  database            = snowflake_database.db.name
  schema              = snowflake_schema.schema.name
  storage_integration = snowflake_storage_integration.integration.name
}

resource "snowflake_external_table" "external_table" {
  database = snowflake_database.db.name
  schema   = snowflake_schema.schema.name
  name     = "external_table"
  comment  = "an external table  that reads JSON data from staged files"
  column {
    as   = "customer"
    name = "id"
    type = "VARIANT"
  }
  file_format = "TYPE = JSON"
  location = "@TF_DEMO.TEST.EXAMPLE_STAGE"
  # location = "s3://ion-lakeformation-raw/input/load/files/path/"
}

# resource "snowflake_stage_grant" "grant_example_stage" {
#   database_name = snowflake_stage.example_stage.database
#   schema_name   = snowflake_stage.example_stage.schema
#   #   roles         = ["LOADER"]
#   #   privilege     = "OWNERSHIP"
#   #   stage_name    = snowflake_stage.example_stage.name
# }



# resource "snowflake_warehouse" "warehouse" {
#   name           = "TF_DEMO"
#   warehouse_size = "large"
#   auto_suspend   = 60
# }