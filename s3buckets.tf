resource "aws_s3_bucket" "lf-user-buckets" {
  count  = length(var.s3_bucket_names) //count will be 3
  bucket = var.s3_bucket_names[count.index]
}
resource "aws_s3_bucket_versioning" "S3_versioning" {
  count  = length(var.s3_bucket_names) //count will be 3
  bucket = var.s3_bucket_names[count.index]
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_acl" "s3_acl" {
  count  = length(var.s3_bucket_names) //count will be 3
  bucket = var.s3_bucket_names[count.index]
  acl    = "private"
}

resource "aws_kms_key" "key_for_dl_buckets" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3-bucket-encryption" {
  count  = length(var.s3_bucket_names) //count will be 3
  bucket = var.s3_bucket_names[count.index]
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.key_for_dl_buckets.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_object" "raw_bucket_object" {
  bucket   = aws_s3_bucket.lf-user-buckets[1].id
  for_each = toset(["input/", "output/", "athena/"])
  key      = each.key

}

resource "aws_lakeformation_resource" "add-buckets-to-resource" {
  count    = length(var.s3_bucket_names)
  arn      = aws_s3_bucket.lf-user-buckets[count.index].arn
  role_arn = aws_iam_role.s3-service-role.arn
}

resource "aws_iam_role" "s3-service-role" {
  name = "s3-buckets-service-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "s3.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "All_S3_SQS_Policy"
    policy = jsonencode({

      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "VisualEditor0",
          "Effect" : "Allow",
          "Action" : [
            "sqs:DeleteMessage",
            "sqs:GetQueueUrl",
            "sqs:ChangeMessageVisibility",
            "sqs:ReceiveMessage",
            "sqs:SendMessage",
            "sqs:GetQueueAttributes",
            "sqs:ListQueueTags",
            "sqs:RemovePermission",
            "sqs:ListDeadLetterSourceQueues",
            "sqs:PurgeQueue",
            "sqs:DeleteQueue",
            "sqs:CreateQueue",
            "sqs:SetQueueAttributes"
          ],
          "Resource" : "arn:aws:sqs:us-east-1:780703661110:sf-snowpipe-AIDA3LRMQPQ3BKU5KZIBM-jWlr8jQs1htnSu6h-pd-cA"
        }
      ]
      }

    )
  }

}