# SNOWFLAKE_USER="tf-snow"
# SNOWFLAKE_ACCOUNT="RCB87966"
# SNOWFLAKE_REGION="AWS_US_EAST_1"
# SNOWFLAKE_PRIVATE_KEY_PATH="~/.ssh/snowflake_tf_snow_key"

variable "password" {
  type        = string
  description = "Snowflake password"
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