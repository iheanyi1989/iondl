##NCREATE NEW VPC OR RETRIEVE VPC DETAILS FROM CLIENT
###RESOURCE BELOW USES ACCOUNTS DEFAULT VPC

resource "aws_default_vpc" "default_vpc_data" {
  tags = {
    Name = "Default VPC"
  }
}
 
data "aws_subnets" "selected_subnets" {
  filter {
    name   = "vpc-id"
    values = [resource.aws_default_vpc.default_vpc_data.id]
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_default_vpc.default_vpc_data.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a new replication subnet group
resource "aws_dms_replication_subnet_group" "test" {
  replication_subnet_group_description = "Test replication subnet group"
  replication_subnet_group_id          = "test-dms-replication-subnet-group-tf"
  subnet_ids = data.aws_subnets.selected_subnets.ids

  tags = {
    Name = "test"
  }
}

# Database Migration Service requires the below IAM Roles to be created before
# replication instances can be created. See the DMS Documentation for
# additional information: https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Security.html#CHAP_Security.APIRole
#  * dms-vpc-role
#  * dms-cloudwatch-logs-role
#  * dms-access-for-endpoint

data "aws_iam_policy_document" "dms_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["dms.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "dms-access-for-endpoint" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-access-for-endpoint"
}

resource "aws_iam_role_policy_attachment" "dms-access-for-endpoint-AmazonDMSRedshiftS3Role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSRedshiftS3Role"
  role       = aws_iam_role.dms-access-for-endpoint.name
}

resource "aws_iam_role" "dms-cloudwatch-logs-role" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-cloudwatch-logs-role"
}

resource "aws_iam_role_policy_attachment" "dms-cloudwatch-logs-role-AmazonDMSCloudWatchLogsRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
  role       = aws_iam_role.dms-cloudwatch-logs-role.name
}

resource "aws_iam_role" "dms-vpc-role" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-vpc-role"
}

resource "aws_iam_role_policy_attachment" "dms-vpc-role-AmazonDMSVPCManagementRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
  role       = aws_iam_role.dms-vpc-role.name
}

# Create a new replication instance
resource "aws_dms_replication_instance" "datalake_replication_instance" {
  allocated_storage            = 20
  apply_immediately            = true
  auto_minor_version_upgrade   = true
  kms_key_arn                  = aws_kms_key.key_for_dl_buckets.arn
  multi_az                     = false
  preferred_maintenance_window = "sun:10:30-sun:14:30"
  replication_instance_class   = "dms.t2.micro"
  replication_instance_id      = "test-dms-replication-instance-tf"
  replication_subnet_group_id  = aws_dms_replication_subnet_group.test.id

  tags = {
    Name = "test"
  }


  vpc_security_group_ids = [
    resource.aws_default_security_group.default.id
  ]

  depends_on = [
    aws_iam_role_policy_attachment.dms-access-for-endpoint-AmazonDMSRedshiftS3Role,
    aws_iam_role_policy_attachment.dms-cloudwatch-logs-role-AmazonDMSCloudWatchLogsRole,
    aws_iam_role_policy_attachment.dms-vpc-role-AmazonDMSVPCManagementRole
  ]
}

# resource "aws_dms_endpoint" "source_endpoint_one" {
#     endpoint_id = "sales-audit"
#     endpoint_type = "source"
#     engine_name = "sqlserver"
#     kms_key_arn =  used to encrypt connection parameters
#     server_name =
#     secrets_manager_access_role_arn = resource.aws_iam_role.role_for_dl.arn
#     secrets_manager_arn = 

# }

resource "aws_dms_endpoint" "target_endpoint_one" {
    endpoint_id = "s3-target-endpoint"
    endpoint_type = "source"
    engine_name = "s3"
    kms_key_arn =  resource.aws_kms_key.key_for_dl_buckets.arn
    s3_settings {
      service_access_role_arn = resource.aws_iam_role.role_for_dl.arn
      add_column_name = "true"
      bucket_folder = "from-dms"
      bucket_name = aws_s3_bucket.lf-user-buckets[1].id
      cdc_inserts_and_updates = "true"
      data_format = "parquet"
      encryption_mode = "SSE_KMS"
      server_side_encryption_kms_key_id = resource.aws_kms_key.key_for_dl_buckets.arn

    }
    # server_name =
    # secrets_manager_access_role_arn = resource.aws_iam_role.role_for_dl.arn
    # secrets_manager_arn = 

}