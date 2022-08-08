# SNOWFLAKE_USER="tf-snow"
# SNOWFLAKE_ACCOUNT="RCB87966"
# SNOWFLAKE_REGION="AWS_US_EAST_1"
# SNOWFLAKE_PRIVATE_KEY_PATH="~/.ssh/snowflake_tf_snow_key"

variable "password" {
  type        = string
  description = "Snowflake password"
  default = "ACCOUNTADMIN"
}

variable "account" {
  type = string
  default = "RCB87966.us-east-1"
}
variable "role" {
  type = string
  default = ""
}
variable "username" {
  type = string
  default = "IONAWSINFRA"
}

variable "snowflake_account_arn" {
  type = string
  default = "arn:aws:iam::780703661110:user/os310000-s"
}
variable "snowflake_external_id" {
  type = string
  default = "RCB87966_SFCRole=2_z5OrfXV7Dxt1XMt/pibpgcvkZwE="
}

# resource "snowflake_external_table" "TEST_EXTERNAL_TABLE" {
  # depends_on = [resource.snowflake_schema.schema, resource.snowflake_database.db]
  # database   = snowflake_database.db.name
  # schema     = snowflake_schema.schema.name
  # name       = "external_table"
  # comment    = "an external table  that reads JSON data from staged files"
  # column {
  #   name = "id"
  #   type = "VARCHAR"
  #   as   = "METADATA$FILENAME"
  # }
  # #file_format = "TYPE = CSV"
#   location    = "@TF_DEMO.TEST.TEST_STAGE"
  
# }

data "snowflake_external_table" "TEST_EXTERNAL_TABLE" {
    database   = snowflake_database.db.name
    schema     = snowflake_schema.schema.name
}



# Do not change the order of these default values. it will force the build to destory and rebuid
variable "s3_bucket_names" {
  type = list(any)
  default = ["processeduserbucket1-iongee",
    "rawuserbucket2-iongee",
    "curateduserbucket3-iongee"
  ]
}

variable "s3_raw_bucket_folders" {
  type = list(any)
  default = ["input/",
    "output/",
    "athena/"
  ]

}