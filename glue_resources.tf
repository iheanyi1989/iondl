resource "aws_glue_catalog_database" "aws_glue_catalog_database1" {
  name         = "catalogdbraw"
  location_uri = "s3://rawuserbucket2-iongee/raw-db/"

  #   create_table_default_permission {
  #     permissions = ["SELECT"]

  #     principal {
  #       data_lake_principal_identifier = "IAM_ALLOWED_PRINCIPALS"
  #     }
  #   }
}

resource "aws_glue_catalog_database" "aws_glue_catalog_database2" {
  name         = "catalogdb2"
  location_uri = "s3://processeduserbucket1-iongee/processed-db/"

  #   create_table_default_permission {
  #     permissions = ["SELECT"]

  #     principal {
  #       data_lake_principal_identifier = "IAM_ALLOWED_PRINCIPALS"
  #     }
  #   }
}

resource "aws_glue_catalog_database" "aws_glue_catalog_database3" {
  name         = "catalogdb3"
  location_uri = "s3://curateduserbucket3-iongee/curated-db/"

  #   create_table_default_permission {
  #     permissions = ["SELECT"]

  #     principal {
  #       data_lake_principal_identifier = "IAM_ALLOWED_PRINCIPALS"
  #     }
  #   }
}