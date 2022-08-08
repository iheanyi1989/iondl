

resource "snowflake_storage_integration" "integration" {
  name                      = upper("test")
  comment                   = "Storage integration used to read files from S3 staging bucket"
  type                      = "EXTERNAL_STAGE"
  storage_provider          = "S3"
  enabled                   = true
  storage_allowed_locations = ["s3://rawuserbucket2-iongee/"]
  storage_aws_role_arn      = resource.aws_iam_role.snowflake_role.arn
}

resource "snowflake_database" "db" {
  name    = "TF_DEMO"
  comment = "Database for Snowflake Ingestion Pipeline (SIP) project"
}

resource "snowflake_schema" "schema" {
  database = snowflake_database.db.name
  name     = "TEST"
  comment  = "Schema from TEST source system"

  is_transient = false
  is_managed   = false
}

resource "snowflake_stage" "example_stage" {
  name                = "TEST_STAGE"
  url                 = "s3://rawuserbucket2-iongee/input/load"
  database            = snowflake_database.db.name
  schema              = snowflake_schema.schema.name
  storage_integration = snowflake_storage_integration.integration.name
}

resource "snowflake_external_table" "external_table" {
  depends_on = [resource.snowflake_schema.schema, resource.snowflake_database.db]
  database   = snowflake_database.db.name
  schema     = snowflake_schema.schema.name
  name       = "external_table"
  comment    = "an external table  that reads JSON data from staged files"
  column {
    name = "id"
    type = "VARCHAR"
    as   = "METADATA$FILENAME"
  }
  file_format = "TYPE = CSV"
  location    = "@TF_DEMO.TEST.TEST_STAGE"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  depends_on = [aws_s3_bucket.lf-user-buckets]
  bucket     = aws_s3_bucket.lf-user-buckets[1].id

  queue {
    id            = "image-upload-event"
    queue_arn     = "arn:aws:sqs:us-east-1:780703661110:sf-snowpipe-AIDA3LRMQPQ3BKU5KZIBM-jWlr8jQs1htnSu6h-pd-cA"
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "input/"
    filter_suffix = ".gz"
  }

  queue {
    id            = "video-upload-event"
    queue_arn     = "arn:aws:sqs:us-east-1:780703661110:sf-snowpipe-AIDA3LRMQPQ3BKU5KZIBM-jWlr8jQs1htnSu6h-pd-cA"
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "athena/"
    filter_suffix = ".gz"
  }
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