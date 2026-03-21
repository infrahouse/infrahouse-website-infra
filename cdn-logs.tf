module "cdn_access_logs" {
  source        = "registry.infrahouse.com/infrahouse/s3-bucket/aws"
  version       = "0.3.1"
  bucket_name   = local.cdn_logs_bucket_name
  enable_acl    = true
  bucket_policy = data.aws_iam_policy_document.cdn_logs_bucket_policy.json
}

data "aws_iam_policy_document" "cdn_logs_bucket_policy" {
  statement {
    sid    = "AllowCloudFrontLogDelivery"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${local.cdn_logs_bucket_name}/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cdn_access_logs" {
  bucket = module.cdn_access_logs.bucket_name

  rule {
    id     = "expire-logs"
    status = "Enabled"

    expiration {
      days = 365
    }
  }
}
